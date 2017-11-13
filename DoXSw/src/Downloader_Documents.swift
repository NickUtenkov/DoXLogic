//
//  Downloader_Documents.swift
//  DoXSw
//
//  Created by Nick Utenkov on 25/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_Documents : DataDownloader
{
	private var m_bCanceled = true
	//NSMutableArray *m_uploadOperationsErrors,*m_linkedDocsForDownload
	
	private var m_requestDoc_FormatStr = ""
	private var m_maxDocs = 0,m_cDocumentsDownloaded = 0,m_cDocumentsExists = 0,m_cDocumentsToDownload = 0
	//var currentOperation:Operation?
	private var m_moc:NSManagedObjectContext

	init(_ moc:NSManagedObjectContext)
	{
		m_moc = moc
		super.init()
	}

	override func main()
	{
		if isCancelled {return}
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updatePartialText("")
			SynchFuncs.synchProgress_updatePartialPercentage(0)
			SynchFuncs.synchProgress_refresh()
		}
		m_requestName = "RequestName_DocList".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestDocumentsIds")
		let str = try? String(contentsOfFile:filePath,encoding:.ascii)
		let requestDoc = String(format:str!,Utils.getEClassesString())
		m_dataXML = requestDoc.data(using:.ascii)
		#else
		dlURL = Utils.createURL("AnswerDocumentsId0")
		#endif
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
		super.main()
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getDocumentsId"]
		{
			if XMLFuncs.getSuccessAttributeValue(elem) == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Documents Ids failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical),object:errMessage)
				return
			}

			m_maxDocs = Utils.prefsGetInteger(GlobDat.kKey_MaxDocCount)
			if m_maxDocs == 0 {m_maxDocs = 50}
			
			var mapDocs:Dictionary<Int,DocMO> = [:]
			var docsToDownload:Array<DocMO> = []
			var docTaskedIds:Set<Int> = []

			let itemsList = elem["documents"].children.filter({ $0.name == "item" })
			for item in itemsList
			{
				let docId = Int(item.attributes["id"]!)!
				if let pDocMO:DocMO = CorDatFuncs.fetchOneRecord(NSPredicate(format:"docId==%d",docId),DocMO.fetchRequest(),m_moc)
				{
					mapDocs[docId] = pDocMO
				}
				docTaskedIds.insert(docId)//docs inserted to collection have tasks
			}

			if mapDocs.count < m_maxDocs
			{
				for item in itemsList
				{
					let docId = Int(item.attributes["id"]!)!
					if mapDocs.index(forKey:docId) != nil {continue}
					let pDocMO = NSEntityDescription.insertNewObject(forEntityName: "Document", into: m_moc) as! DocMO
					pDocMO.docId = docId
					pDocMO.version = 0
					pDocMO.visible = false
					//if (getCurDoc() == docId) [[NSNotificationCenter defaultCenter] postNotificationName:kDocArrived object:nil]
					mapDocs[docId] = pDocMO
					if mapDocs.count >= m_maxDocs {break}
				}
			}

			for item in itemsList
			{
				let attrs = item.attributes
				let docId = Int(attrs["id"]!)!
				if let pDocMO = mapDocs[docId]//.index(forKey:docId)
				{
					let version = XMLFuncs.getVersionFromAttrs(attrs)
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:docId)
					if GlobDat.bDisableCheckDocumentVersion || (pDocMO.version < version) || shouldDownloadAttachments(pDocMO)
					{
						pDocMO.visible = false
						docsToDownload.append(pDocMO)
					}
					else
					{
						//doesn't check m_cDocumentsExists < m_maxDocs - these docs are not downloaded
						m_cDocumentsExists += 1
						removeAdditionalsFromToDeleteList(pDocMO)
					}
				}
			}
			m_cDocumentsToDownload = Int(docsToDownload.count)
			removeTasksForNotTaskedDocuments(docTaskedIds)

			let moc = CoreDataManager.sharedInstance.createWorkerContext()
			let req:NSFetchRequest<FolderPresMO> = FolderPresMO.fetchRequest()
			var arFolders:[FolderPresMO] = []
			if let arFolders1 = try? moc.fetch(req)
			{
				arFolders = arFolders1
			}
			
			var mapDocFolders:Dictionary<Int,Set<Int>> = [:]

			let presentationsItems = elem["presentations"].children.filter({ $0.name == "item" })
			for item in presentationsItems
			{
				let attrs = item.attributes
				let folderId = Int(attrs["id"]!)!
				let idx = arFolders.index(where: {$0.folderId == folderId})
				if idx == nil
				{
					let pFolderRec = NSEntityDescription.insertNewObject(forEntityName: "PresentationFolder", into: m_moc) as! FolderPresMO
					pFolderRec.folderId = folderId
					pFolderRec.folderName = attrs["name"]
					if let strOrder = attrs["nord"] {pFolderRec.nOrder = Int(strOrder)!}
				}
				else {arFolders.remove(at: idx!)}
				var nOrder = 1
				let docsItems = item["documents"].children.filter({ $0.name == "item" })
				for docItem in docsItems
				{
					let attrs = docItem.attributes
					let docId = Int(attrs["id"]!)!
					if let pDocMO:DocMO = mapDocs[docId]
					{
						pDocMO.addToFolder(folderId,nil,nOrder)
						Utils.addDocFolderToMap(&mapDocFolders,docId,folderId)
					}
					nOrder += 1
				}
			}

			for (docId,pDocMO) in mapDocs
			{
				if let setFolders:Set<Int> = mapDocFolders[docId]
				{
					for pFolder in pDocMO.foldersList!
					{
						if !setFolders.contains(pFolder.folderId)
						{
							pDocMO.removeFromFolder(pFolder.folderId)
						}
					}
				}
			}

			for pFolderRec in arFolders {moc.delete(pFolderRec)}
			CoreDataManager.sharedInstance.saveContext(moc)

			for (_,pDocMO) in mapDocs
			{
				pDocMO.visible = false
			}
			CoreDataManager.sharedInstance.saveContext(self.m_moc)

			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kPresentationsDownloaded),object:0)

			Utils.runOnUI{SynchFuncs.synchProgress_updatePartialHeader("RequestGroupName_MainDocs".localized)}
			updateDocProgress()
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kGroup1DocCount),object:m_cDocumentsToDownload)
			Thread.sleep(forTimeInterval:0.1)//for progress updated incrementally

			m_bCanceled = false
			if m_cDocumentsToDownload > 0
			{
				let nc = NotificationCenter.`default`
				
				nc.addObserver(self, selector:#selector(self.processDocumentAccepted), name:NSNotification.Name(rawValue:GlobDat.kDocumentAccepted), object:nil)

				#if !LocalXML
				let filePath = Utils.getXMLFilePathFromResource("RequestDocument")
				m_requestDoc_FormatStr = try! String(contentsOfFile:filePath, encoding:.ascii)
				#endif

				for pDocMO in docsToDownload
				{
					runDownloader(pDocMO)
					if m_bCanceled {break}
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kAddToDownloadedDoc),object:pDocMO.docId)
					if m_cDocumentsExists >= m_maxDocs {break}
				}

				nc.removeObserver(self, name:NSNotification.Name(rawValue:GlobDat.kDocumentAccepted),object:nil)
			}
			if !m_bCanceled
			{
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocListLoaded),object:nil)//for counting requests
				//NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kGroup2DocCount),object:m_linkedDocsForDownload.count)
			}
		}
	}

	func runDownloader(_ pDocMO:DocMO)
	{
		var data:Data? = nil 
		#if !LocalXML
		let requestStr = String(format:m_requestDoc_FormatStr,pDocMO.docId)
		data = requestStr.data(using: .ascii)
		let url = Utils.createURL()
		#else
		let url = Utils.createURL(String(format:"AnswerDoc_%d",pDocMO.docId))
		#endif
		let docPortionDownloader = Downloader_Doc(url,data,pDocMO)
		//currentOperation = docPortionDownloader
		docPortionDownloader.start()
		m_bCanceled = !docPortionDownloader.isSuccess()
		//currentOperation = nil
	}

	@objc func processDocumentAccepted(notification: NSNotification)
	{
		m_cDocumentsDownloaded += 1
		m_cDocumentsExists += 1
		#if LocalXML//docs number in local XML can be greater then maxDocs
		if m_cDocumentsExists>m_maxDocs {m_cDocumentsExists = m_maxDocs}
		#endif
		updateDocProgress()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kGroup1DocArrived),object:nil)
		Thread.sleep(forTimeInterval:0.1)//for progress updated incrementally
		#if LocalXML1
		Thread.sleep(forTimeInterval:1.0)
		#endif
	}

	func updateDocProgress()
	{
		let str = String(format:"%d/%d",m_cDocumentsDownloaded,m_cDocumentsToDownload)
		var divider = min(m_cDocumentsToDownload,Int(m_maxDocs))
		if divider == 0 {divider = 1}
		let percent = m_cDocumentsDownloaded*100/divider
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updatePartialText(str)
			SynchFuncs.synchProgress_updatePartialPercentage(Int(percent))
		}
	}

	func removeTasksForNotTaskedDocuments(_ docTaskedIds:Set<Int>)
	{
		let moc = CoreDataManager.sharedInstance.createWorkerContext()
		let req:NSFetchRequest<DocMO> = DocMO.fetchRequest()
		let predic:NSPredicate = .init(format:"ANY tasks != nil")
		req.predicate = predic
		if let arDocs:[DocMO] = try? moc.fetch(req)
		{
			for pDocMO in arDocs
			{
				let docId = pDocMO.docId
				if !docTaskedIds.contains(docId)
				{
					if GlobDat.curDocId != docId
					{
						let selRemoveTask = #selector(pDocMO.removeFromTasks as (_ value: TaskUnprocessed) -> Void)
						CorDatFuncs.removeRelationshipObjects(pDocMO,pDocMO.tasks!,selRemoveTask,true)
					}
					else
					{
						let arTasks = Array(pDocMO.tasks!)
						for pTask in arTasks
						{
							if pTask.taskId != GlobDat.curTask
							{
								pDocMO.removeFromTasks(pTask)
								moc.delete(pTask)
							}
							NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocTaskDeleted),object:pTask)
						}
					}
				}
			}
		}
		CoreDataManager.sharedInstance.saveContext(moc)
	}

	func removeAdditionalsFromToDeleteList(_ pDocMO:DocMO)
	{
		for pTask in pDocMO.tasks!
		{
			if pTask.outputDocSet != nil
			{
				for pLinkedRec in pTask.outputDocSet!
				{
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:pLinkedRec.linkedId)
				}
			}
			if pTask.childTasksSet != nil
			{
				for pChildTaskRec in pTask.childTasksSet!
				{
					for pDocMO in pChildTaskRec.docSet!
					{
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:pDocMO.docId)
					}
				}
			}
		}
	}

	func shouldDownloadAttachments(_ pDocMO:DocMO) -> Bool
	{
		for pDocAtt in pDocMO.attSet!
		{
			if Utils.getFileSize(pDocAtt.fileId) != pDocAtt.fileSize {return true}
		}
		
		for pTask in pDocMO.tasks!
		{
			for pLinkedRec in pTask.outputFiles!
			{
				let attId = pLinkedRec.linkedId
				let pDocAtt = pLinkedRec.file
				if Utils.getFileSize(attId) != pDocAtt!.fileSize {return true}
			}
			for pLinkedRec in pTask.reportFiles!
			{
				let attId = pLinkedRec.linkedId
				let pDocAtt = pLinkedRec.file
				if Utils.getFileSize(attId) != pDocAtt!.fileSize {return true}
			}
			for pChildTaskRec in pTask.childTasksSet!
			{
				for pDocAtt in pChildTaskRec.outputFiles!
				{
					if Utils.getFileSize(pDocAtt.fileId) != pDocAtt.fileSize {return true}
				}
				for pDocAtt in pChildTaskRec.reportFiles!
				{
					if Utils.getFileSize(pDocAtt.fileId) != pDocAtt.fileSize {return true}
				}
			}
		}

		for pDocLinked in pDocMO.linkedDocs!
		{
			for pDocAtt in pDocLinked.attSet!
			{
				if Utils.getFileSize(pDocAtt.fileId) != pDocAtt.fileSize {return true}
			}
		}
		return false
	}
}
