//
//  Synchronizer.swift
//  DoXSw
//
//  Created by nick on 21/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class Synchronizer
{
	private var m_bCanFinishSync = true
	private var m_pQueue:OperationQueue = .init()
	
	private var m_bManualSynchronization = false
	
	private var m_strSevereError:String? = nil
	private var m_cSynchMessages = 0
	private var m_countDocRequestCompleted = 0,m_countDocRequests = 0
	
	private var cGroupRequestsForNotifier = 0,cGroupRequests = 0,curRequestInGroup = 0,cAllGroupRequests = 0,curRequestInAllGroups = 0
	private var grp1DocCount = 0,grp2DocCount = 0,grp3DocCount = 0
	private var grp1CurCount = 0,grp2CurCount = 0,grp3CurCount = 0
	private var grp0Weight = 10,grp1Weight = 60,grp2Weight = 20,grp3Weight = 10
	private var grp0TimeBegin = Date(),grp1TimeBegin = Date(),grp2TimeBegin = Date(),grp3TimeBegin = Date()
	private let m_moc = CoreDataManager.sharedInstance.createWorkerContext()
	private var contactsToDelete:Dictionary<Int,ContactMO> = [:]
	private var contactsToDeleteFavorite:Dictionary<Int,ContactMO> = [:]
	private var contactsToDeleteAffilate:Dictionary<Int,ContactMO> = [:]
	private var docIdsToDelete:Set<Int> = []
	private var docIdsDownloaded:Set<Int> = []
	private var attachmentsToDelete:Dictionary<Int,DocContentMO> = [:]
	static var attachmentsToDownload:Set<Int> = []

	init()
	{
		m_pQueue.maxConcurrentOperationCount = 1
		m_pQueue.isSuspended = true
		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.processAuthorizationFailed), name:NSNotification.Name(rawValue:GlobDat.kAuthorizationFailed), object:nil)
		nc.addObserver(self, selector:#selector(self.processSevereSyncError), name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical), object:nil)
		nc.addObserver(self, selector:#selector(self.processDocListLoaded), name:NSNotification.Name(rawValue:GlobDat.kDocListLoaded), object:nil)
		nc.addObserver(self, selector:#selector(self.logDownLoadError), name:NSNotification.Name(rawValue:GlobDat.kSynchErrorLoggableDownload), object:nil)
		nc.addObserver(self, selector:#selector(self.newRequestsGroup), name:NSNotification.Name(rawValue:GlobDat.kNewRequestsGroup), object:nil)
		nc.addObserver(self, selector:#selector(self.requestInGroupCompleted), name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted), object:nil)
		nc.addObserver(self, selector:#selector(self.requestGroup1DocCountCompleted), name:NSNotification.Name(rawValue:GlobDat.kGroup1DocCount), object:nil)
		nc.addObserver(self, selector:#selector(self.requestGroup2DocCountCompleted), name:NSNotification.Name(rawValue:GlobDat.kGroup2DocCount), object:nil)
		nc.addObserver(self, selector:#selector(self.requestGroup3DocCountCompleted), name:NSNotification.Name(rawValue:GlobDat.kGroup3DocCount), object:nil)
		nc.addObserver(self, selector:#selector(self.group1DocArrived), name:NSNotification.Name(rawValue:GlobDat.kGroup1DocArrived), object:nil)
		nc.addObserver(self, selector:#selector(self.group2DocArrived), name:NSNotification.Name(rawValue:GlobDat.kGroup2DocArrived), object:nil)
		nc.addObserver(self, selector:#selector(self.group3DocArrived), name:NSNotification.Name(rawValue:GlobDat.kGroup3DocArrived), object:nil)
		nc.addObserver(self, selector:#selector(self.processRemoveFromDeleteContact), name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteContact), object:nil)
		nc.addObserver(self, selector:#selector(self.processRemoveFromDeleteFavorite), name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteFavorite), object:nil)
		nc.addObserver(self, selector:#selector(self.processRemoveFromDeleteAffilate), name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteAffilate), object:nil)
		nc.addObserver(self, selector:#selector(self.processRemoveFromDeleteDoc), name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc), object:nil)
		nc.addObserver(self, selector:#selector(self.addToDownloadedDoc), name:NSNotification.Name(rawValue:GlobDat.kAddToDownloadedDoc), object:nil)
		nc.addObserver(self, selector:#selector(self.removeFromDeleteAtt), name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteAtt), object:nil)
	}

	func stopOperations()
	{
		m_pQueue.cancelAllOperations()
		m_pQueue.isSuspended = false//should call this for all operation started/finished & removed from queue
	}

	@objc func processAuthorizationFailed(notification: NSNotification)
	{//@objc used because we are not subclass of NSObject(or UIViewController etc)
		m_bCanFinishSync = true//false
		m_strSevereError = "Authorization failed"
		GlobDat.bDoLogin = true
		stopOperations()//will exit from waitUntilAllOperationsAreFinished
	}

	@objc func processSevereSyncError(notification: NSNotification)
	{
		if notification.object != nil
		{
			m_strSevereError = notification.object as! String?
			print(m_strSevereError!)
		}
		stopOperations()//will exit from waitUntilAllOperationsAreFinished
		GlobDat.bDoLogin = true
	}

	@objc func processDocListLoaded(notification: NSNotification)
	{
		m_countDocRequestCompleted += 1
	}

	@objc func logDownLoadError(notification: NSNotification)
	{
		let errStr = notification.object as! String?
		CorDatFuncs.addError(errStr)
		m_cSynchMessages += 1
	}

	@objc func newRequestsGroup(notification: NSNotification)
	{
		cGroupRequests = notification.object as! Int
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updatePartialPercentage(0)
			SynchFuncs.synchProgress_refresh()
		}
	}

	@objc func requestInGroupCompleted(notification: NSNotification)
	{
		curRequestInGroup += 1
		let percent = curRequestInGroup*100/cGroupRequests

		curRequestInAllGroups += 1
		let percent0 = curRequestInAllGroups*grp0Weight/cAllGroupRequests

		let speed0 = Double(curRequestInAllGroups)/Date().timeIntervalSince(grp0TimeBegin)
		let secondsLeft = Double(cAllGroupRequests - curRequestInAllGroups)*speed0

		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updatePartialPercentage(percent)
			SynchFuncs.synchProgress_updateTotalPercentage(percent0)
			SynchFuncs.synchProgress_updatePartialTimeLeft(Int(ceil(secondsLeft)))
			SynchFuncs.synchProgress_refresh()
		}
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUpdateButtonProgress),object:percent0)
		#if LocalXML
		Thread.sleep(forTimeInterval:0.5)
		#endif
	}

	@objc func requestGroup1DocCountCompleted(notification: NSNotification)
	{
		var maxDocs = Utils.prefsGetInteger(GlobDat.kKey_MaxDocCount)
		if maxDocs == 0 {maxDocs = 50}
		grp1DocCount = min(notification.object as! Int,Int(maxDocs))
		grp1TimeBegin = Date()
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_resetPartialTimeLeft()
			SynchFuncs.synchProgress_refresh()
		}
	}

	@objc func requestGroup2DocCountCompleted(notification: NSNotification)
	{
		grp2DocCount = notification.object as! Int
		grp2TimeBegin = Date()
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_resetPartialTimeLeft()
			SynchFuncs.synchProgress_refresh()
		}
	}

	@objc func requestGroup3DocCountCompleted(notification: NSNotification)
	{
		grp3DocCount = notification.object as! Int
		grp3TimeBegin = Date()
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_resetPartialTimeLeft()
			SynchFuncs.synchProgress_refresh()
		}
	}

	@objc func group1DocArrived(notification: NSNotification)
	{
		grp1CurCount += 1
		var curPercent = (grp1CurCount*grp1Weight)/grp1DocCount
		if curPercent > grp1Weight {curPercent = grp1Weight}
		curPercent += grp0Weight
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUpdateButtonProgress),object:curPercent)
		let oneDocTime1 = Date().timeIntervalSince(grp1TimeBegin)/Double(grp1CurCount)
		let secondsLeft = oneDocTime1*Double(grp1DocCount - grp1CurCount)
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updateTotalPercentage(curPercent)
			SynchFuncs.synchProgress_updatePartialTimeLeft(Int(ceil(secondsLeft)))
			SynchFuncs.synchProgress_refresh()
		}
		//CATransaction.flush()//commit
	}

	@objc func group2DocArrived(notification: NSNotification)
	{
		grp2CurCount += 1
		let curPercent = (grp2CurCount*grp2Weight)/grp2DocCount+grp0Weight+grp1Weight
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUpdateButtonProgress),object:curPercent)
		let oneDocTime2 = Date().timeIntervalSince(grp2TimeBegin)/Double(grp2CurCount)
		let secondsLeft = oneDocTime2*Double(grp2DocCount - grp2CurCount)
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updateTotalPercentage(curPercent)
			SynchFuncs.synchProgress_updatePartialTimeLeft(Int(ceil(secondsLeft)))
			SynchFuncs.synchProgress_refresh()
		}
		//CATransaction.flush()//commit
	}

	@objc func group3DocArrived(notification: NSNotification)
	{
		grp3CurCount += 1
		let curPercent = (grp3CurCount*grp3Weight)/grp3DocCount+grp0Weight+grp1Weight+grp2Weight
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUpdateButtonProgress),object:curPercent)
		let oneDocTime3 = Date().timeIntervalSince(grp3TimeBegin)/Double(grp3CurCount)
		let secondsLeft = oneDocTime3*Double(grp3DocCount - grp3CurCount)
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updateTotalPercentage(curPercent)
			SynchFuncs.synchProgress_updatePartialTimeLeft(Int(ceil(secondsLeft)))
			SynchFuncs.synchProgress_refresh()
		}
		//CATransaction.flush()//commit
	}

	@objc func processRemoveFromDeleteContact(notification: NSNotification)
	{
	}

	@objc func processRemoveFromDeleteFavorite(notification: NSNotification)
	{
	}

	@objc func processRemoveFromDeleteAffilate(notification: NSNotification)
	{
	}

	@objc func processRemoveFromDeleteDoc(notification: NSNotification)
	{
	}

	@objc func addToDownloadedDoc(notification: NSNotification)
	{
	}

	@objc func removeFromDeleteAtt(notification: NSNotification)
	{
	}

	func addToQueue(_ oper:Operation)
	{
		m_pQueue.addOperation(oper)
		cGroupRequestsForNotifier += 1
	}

	func getAllContacts()
	{//http://fuckingswiftblocksyntax.com
		let req:NSFetchRequest<ContactMO> = ContactMO.fetchRequest()
		m_moc.performAndWait
		{
			if let contacts:[ContactMO] = try? m_moc.fetch(req)
			{
				for contact in contacts
				{
					if contact.favorite {contactsToDeleteFavorite[contact.employeeId] = contact}
					else if contact.isAffilate {contactsToDeleteAffilate[contact.employeeId] = contact}
					else {contactsToDelete[contact.employeeId] = contact}
				}
			}
		}
	}

	func markAsNotFavoriteOrAffilate()
	{
		if (contactsToDeleteFavorite.count > 0) || (contactsToDeleteAffilate.count > 0)
		{
			for (key,pContact) in contactsToDeleteFavorite
			{
				pContact.favorite = false
				contactsToDelete[key] = pContact
			}
			for (key,pContact) in contactsToDeleteAffilate
			{
				pContact.isAffilate = false
				contactsToDelete[key] = pContact
			}
			CoreDataManager.sharedInstance.saveContext(m_moc)
		}
	}

	func updatePercent(_ curPercent:Int)
	{
		//print("updatePercent",curPercent)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUpdateButtonProgress),object:curPercent)
		
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updateTotalPercentage(curPercent)
			SynchFuncs.synchProgress_refresh()
		}
		//CATransaction.flush()//commit
		//[NSThread sleepForTimeInterval:0.5]
	}

	func createAllDocAndFolderIdsListBeforeDownLoad()
	{
		let moc = CoreDataManager.sharedInstance.createWorkerContext()
		moc.performAndWait
		{
			let req:NSFetchRequest<DocMO> = DocMO.fetchRequest()
			moc.performAndWait
			{
				if let docRecordsBeforeDownload:[DocMO] = try? moc.fetch(req)
				{
					for pDocMO in docRecordsBeforeDownload {self.docIdsToDelete.insert(pDocMO.docId)}
				}
			}
		}
	}

	func createAttachmentList()
	{
		let moc = CoreDataManager.sharedInstance.createWorkerContext()
		moc.performAndWait
		{
			let req:NSFetchRequest<DocContentMO> = DocContentMO.fetchRequest()
			if let arAtts:[DocContentMO] = try? moc.fetch(req)
			{
				for pAtt in arAtts {self.attachmentsToDelete[pAtt.fileId] = pAtt}
			}
		}
	}

	func doSynchronization()
	{
		//print("doSynchronization")
		var taskId:UIBackgroundTaskIdentifier!
		taskId = UIApplication.shared.beginBackgroundTask(expirationHandler:
		{
			//WriteLog1(@"Program terminated by OS")
		})

		var pProgressPartialTitle = ProgressPartialTitle()
		pProgressPartialTitle.title = "RequestGroupName_Spravochnikov".localized
		addToQueue(pProgressPartialTitle)

		if GlobDat.bDoLogin
		{
			var strPsw = ""
			#if !LocalXML
			strPsw = Utils.prefsGetString(GlobDat.kKey_Password)!
			#endif
			addToQueue(Downloader_DoLogin(password:strPsw))
			m_pQueue.addOperation({GlobDat.bDoLogin = false})
			addToQueue(Downloader_Config())
		}
		if EClasses.count() == 0 {addToQueue(Downloader_EClass())}

		m_pQueue.addOperation({self.getAllContacts()})
		
		addToQueue(Downloader_Employee())
		addToQueue(Downloader_Affilate())
		m_pQueue.addOperation({self.markAsNotFavoriteOrAffilate()})
		addToQueue(Downloader_Autotext())

		pProgressPartialTitle.m_cGroupRequests = cGroupRequestsForNotifier
		cAllGroupRequests += cGroupRequestsForNotifier

		let weight0 = grp0Weight
		m_pQueue.addOperation({self.updatePercent(weight0)})

		pProgressPartialTitle = ProgressPartialTitle()
		pProgressPartialTitle.title = "RequestGroupName_MainDocsList".localized
		addToQueue(pProgressPartialTitle)

		m_pQueue.addOperation({self.createAllDocAndFolderIdsListBeforeDownLoad()})
		m_pQueue.addOperation({self.createAttachmentList()})

		m_countDocRequests += 1
		addToQueue(Downloader_Documents(m_moc))

		let weight1 = grp0Weight + grp1Weight
		m_pQueue.addOperation({self.updatePercent(weight1)})

		let weight2 = grp0Weight + grp1Weight + grp2Weight
		m_pQueue.addOperation({self.updatePercent(weight2)})

		pProgressPartialTitle = ProgressPartialTitle()
		pProgressPartialTitle.title = "RequestGroupName_AcquDocs".localized
		addToQueue(pProgressPartialTitle)

		m_countDocRequests += 1
		addToQueue(Downloader_AcquFolders())
		m_pQueue.addOperation({self.updatePercent(100)})

		grp0TimeBegin = Date()
		
		m_pQueue.isSuspended = false
		m_pQueue.waitUntilAllOperationsAreFinished()
		
		if m_bCanFinishSync {finishSynchronization()}

		Synchronizer.attachmentsToDownload.removeAll()
		
		UIApplication.shared.endBackgroundTask(taskId)

		NotificationCenter.`default`.removeObserver(self)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchronizationFinished),object:0)
	}

	func finishSynchronization()
	{
		//print("finishSynchronization")
		if m_strSevereError == nil {SynchFuncs.synchProgress_switchToView2()}
		else
		{
			SynchFuncs.synchProgress_Destroy(true)
			Utils.runOnUI
			{
				let alrt = UIAlertController(title:"Error".localized,message:self.m_strSevereError!,preferredStyle: .alert)
				let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
				alrt.addAction(okButton)
				UIApplication.shared.windows[0].rootViewController?.present(alrt, animated: true)
			}
		}
	}

	static func addAttToDownload(_ attId:Int)
	{
		attachmentsToDownload.insert(attId)
	}
	
	static func isAttAlreadyAddedToDownload(_ attId:Int) -> Bool
	{
		return attachmentsToDownload.index(of:attId) != nil
	}
}
