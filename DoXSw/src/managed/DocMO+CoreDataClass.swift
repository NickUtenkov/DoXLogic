//
//  DocMO+CoreDataClass.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

enum DocType : Int
{
	case typeNone = 0,typeInput,typeOutput,typeInternal
}

@objc(DocMO)
public class DocMO: NSManagedObject
{
	lazy var tasksUnprocessed:Array<TaskUnprocessed> = 
	{
		return Array()
	}()

	lazy var tasksProcessed:Array<TaskUnprocessed> = 
	{
		return Array()
	}()

	private(set) lazy var attachments:Array<DocContentMO> = 
	{[unowned self] in
		var atts = Array(self.attSet!)
		atts.sort(by:{$1.nOrder > $0.nOrder})//self.compareOrder
		return atts
	}()

	private(set) lazy var arSenders:Array<ContactMO> = 
	{[unowned self] in
		var _arSenders = Array(self.senders!)
		_arSenders.sort(by:{$0.name! < $1.name!})
		return _arSenders
	}()
	
	private(set) lazy var arRecepients:Array<ContactMO> = 
	{[unowned self] in
		var _arRecepients = Array(self.recepients!)
		_arRecepients.sort(by:{$0.name! < $1.name!})
		return _arRecepients
	}()

	/*func compareOrder(_ pAtt1:DocContentMO,_ pAtt2:DocContentMO) -> Bool
	{
		return pAtt2.nOrder > pAtt1.nOrder
	}*/

	func addToFolder(_ folderId:Int,_ date:Date?,_ nOrder:Int)
	{
		var pDFRec:DocFolderMO//? = nil
		if let idx = self.foldersList?.index(where:{$0.folderId == folderId})
		{
			pDFRec = (self.foldersList?[idx])!
		}
		else
		{
			pDFRec = NSEntityDescription.insertNewObject(forEntityName: "DocumentFolders", into: self.managedObjectContext!) as! DocFolderMO
			pDFRec.folderId = folderId
			pDFRec.date = date
			addToFoldersList(pDFRec)
		}
		pDFRec.nOrder = nOrder
	}

	func removeFromFolder(_ folderId:Int)
	{
		if let idx = self.foldersList?.index(where:{$0.folderId == folderId})
		{
			let pDFRec = (self.foldersList?[idx])!
			removeFromFoldersList(pDFRec)
			self.managedObjectContext!.delete(pDFRec)
		}
	}

	func parseAddressees(_ addressees:[AEXMLElement],_ nameContact:String)
	{
		var recepientsBefore = Array(recepients!)
		var sendersBefore = Array(senders!)
		let moc = managedObjectContext!
		let requestContact:NSFetchRequest<ContactMO> = ContactMO.fetchRequest()
		for item in addressees
		{
			if let contact = item.children.filter({ $0.name == "contact" }).first
			{
				let pEmpl = CorDatFuncs.addContact(moc, requestContact, contact, false, false)
				if let role = item.attributes["role"]
				{
					if role == "Recipient"
					{
						let idx = recepientsBefore.index(where: {$0.employeeId == pEmpl.employeeId})
						if idx == nil {addToRecepients(pEmpl)}
						else {recepientsBefore.remove(at: idx!)}
					}
					else if role == "Sender"
					{
						let idx = sendersBefore.index(where: {$0.employeeId == pEmpl.employeeId})
						if idx == nil {addToSenders(pEmpl)}
						else {sendersBefore.remove(at: idx!)}
					}
					else if role == "Addressee" {addresse = pEmpl}
					else if role == "Correspondent" {correspondent = pEmpl}
				}
			}
		}
		for pCon in recepientsBefore
		{
			removeFromRecepients(pCon)
			moc.delete(pCon)
		}
		for pCon in sendersBefore
		{
			removeFromSenders(pCon)
			moc.delete(pCon)
		}
	}

	private(set) lazy var docInfoForAttachments:String = 
	{[unowned self] in
		var headerStr = ""
		if self.inRegistration != nil {headerStr.append(String(format:"№ %@",self.inRegistration!))}
		if self.inDate != nil {headerStr.append(String(format:"Dated".localized,MyDF.dfDateOnly.string(from:self.inDate!)))}
		headerStr.append(String(format:" \"%@\"",self.docTitle!))
		return headerStr
	}()

	func parseExecutionList(_ items:[AEXMLElement],_ requestContact:NSFetchRequest<ContactMO>)
	{
		let moc:NSManagedObjectContext = managedObjectContext!
		for item in items
		{
			let attrs = item.attributes
			let pRec:ExecutionListMO = NSEntityDescription.insertNewObject(forEntityName: "ExecutionList", into: moc) as! ExecutionListMO
			if let executor = item.children.filter({ $0.name == "executor" }).first
			{
				pRec.executor = CorDatFuncs.addContact(moc, requestContact, executor, false, false)
			}
			if let author = item.children.filter({ $0.name == "author" }).first
			{
				pRec.executor = CorDatFuncs.addContact(moc, requestContact, author, false, false)
			}
			pRec.datePlanEnd = Utils.getDateFromString(attrs["datePlanEnd"])
			pRec.dateFactEnd = Utils.getDateFromString(attrs["dateFactEnd"])
			pRec.report = attrs["report"]
			if let strResult = attrs["result"]
			{
				pRec.result = strResult.bool as NSNumber?
			}
			pRec.taskDescription = attrs["description"]
			addToExecutionList(pRec)
		}
	}

	func countAcceptedTaskToMinus(_ bUnproc:Bool) -> Int
	{
		var rc = 0
		let arTasks = bUnproc ? self.tasksUnprocessed : self.tasksProcessed
		for pTask in arTasks
		{
			if pTask.displayEClassId == GlobDat.eClass_AcceptExecution {rc += 1}
		}
		if (rc == 0) || (rc == 1) {return 0}
		return rc-1
	}

	private(set) lazy var addressOrCorrespondent:String =
	{[unowned self] in
		var strAddrOrCor = ""
		if self.docType == .typeInput
		{
			if let adrName = self.addresse?.name  {strAddrOrCor = String(format:"strAddresse".localized,adrName)}
		}
		else if self.docType == .typeOutput
		{
			if let corName = self.correspondent?.name  {strAddrOrCor = String(format:"strCorrespondent".localized,corName)}
		}
		return strAddrOrCor
	}()

	private(set) lazy var documentInfo:String =
	{[unowned self] in
		var strDocInfo = ""
		strDocInfo.append(String(format:"%@. %@",self.type!,self.eclass!))
		if self.inRegistration != nil {strDocInfo.append(String(format:" № %@",self.inRegistration!))}
		if self.inDate != nil {strDocInfo.append(String(format:"Dated".localized,MyDF.dfDateOnly.string(from:self.inDate!)))}
		return strDocInfo
	}()

	private(set) lazy var acquaintanceDeliverDate:Date =
	{[unowned self] in
		var date = Date.distantPast
		for pDFRec in self.foldersList!
		{
			if let dt = pDFRec.date
			{
				if dt > date {date = dt}
			}
		}
		return date
	}()

	private(set) lazy var docType:DocType = 
	{[unowned self] in
		if let strType = self.type
		{//.lowercased() not used
			if strType.range(of:"DocTypeInput".localized) != nil {return .typeInput}
			else if strType.range(of:"DocTypeOutput".localized) != nil {return .typeOutput}
			else if strType.range(of:"DocTypeInternal".localized) != nil {return .typeInternal}
		}
		return .typeNone
	}()
}
