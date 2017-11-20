//
//  Downloader_AcquFolders.swift
//  DoXSw
//
//  Created by Nick Utenkov on 03/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_AcquFolders : DataDownloader
{
	private var cAllDocs = 0,cDocsParsed = 0

	override func main()
	{
		if isCancelled {return}
		Utils.runOnUI
		{
			SynchFuncs.synchProgress_updatePartialText("")
			SynchFuncs.synchProgress_updatePartialPercentage(0)
			SynchFuncs.synchProgress_refresh()
		}
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestAcquaintanceFolders")
		m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
		dlURL = Utils.createURL("AnswerAcquaintanceFolders0")
		#endif
		m_requestName = "RequestName_AcquaintanceFolders".localized
		super.main()
	}

	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getAcquaintanceFolders"]
		{
			if XMLFuncs.getSuccessAttributeValue(elem) == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Acquaintance Folders failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical),object:errMessage)
				return
			}

			var folderIds:[Int] = []
			let cdm = CoreDataManager.sharedInstance
			let moc = cdm.createWorkerContext()
			moc.performAndWait
			{
				let req:NSFetchRequest<FolderMO> = FolderMO.fetchRequest()
				if var arFolders:[FolderMO] = try? moc.fetch(req)
				{
					self.parseFolders(moc,0,elem,&arFolders,&folderIds)
					for pFolderRec in arFolders {moc.delete(pFolderRec)}
				}

				cdm.saveContext(moc)
			}

			getFoldersDocuments(folderIds)
		}
	}

	func parseFolders(_ moc:NSManagedObjectContext,_ parentId:Int,_ elem:AEXMLElement,_ arFolders:inout [FolderMO],_ folderIds:inout [Int])
	{
		let folderItems = elem.children.filter({ $0.name == "item" })
		for folderItem in folderItems
		{
			let itemAttrs = folderItem.attributes
			let folderId = Int(itemAttrs["id"]!)!
			let str = itemAttrs["name"]

			var pFolderRec:FolderMO? = nil
			if let idx = arFolders.index(where:{$0.folderId == folderId})
			{
				pFolderRec = arFolders[idx]
				arFolders.remove(at: idx)
			}
			else
			{
				pFolderRec = NSEntityDescription.insertNewObject(forEntityName: "FoldersHierarchy", into: moc) as? FolderMO
				pFolderRec!.folderId = folderId
				pFolderRec!.folderName = str
			}
			pFolderRec!.folderParentId = parentId
			folderIds.append(folderId)
			if let childsElem = folderItem.children.filter({ $0.name == "childs" }).first
			{
				parseFolders(moc,folderId,childsElem,&arFolders,&folderIds)
			}
		}
	}

	func getFoldersDocuments(_ folderIds:[Int])
	{
		var bCanceled = false
		var folderDocs:Dictionary<Int,Array<DocVersionDate>> = [:]

		for folderId in folderIds
		{
			let folderDocDownloader = Downloader_FolderDocIds(folderId)
			folderDocDownloader.start()
			bCanceled = !folderDocDownloader.isSuccess()
			if bCanceled {break}
			folderDocs[folderId] = folderDocDownloader.getArray()
		}

		if !bCanceled
		{
			var docVersions:Dictionary<Int,Int> = [:]
			for (_,arrayDVD) in folderDocs
			{
				for aDVD in arrayDVD {docVersions[aDVD.docId] = aDVD.version}
			}

			var docsToDownload:[DocMO] = []
			let cdm = CoreDataManager.sharedInstance
			let moc = cdm.createWorkerContext()
			moc.performAndWait
			{
				for (docId,version) in docVersions
				{
					let pDocMO:DocMO
					if let pDocMO1:DocMO = CorDatFuncs.fetchOneRecord(NSPredicate(format:"docId==%d",docId),DocMO.fetchRequest(),moc)
					{
						pDocMO = pDocMO1
					}
					else
					{
						pDocMO = NSEntityDescription.insertNewObject(forEntityName: "Document", into: moc) as! DocMO
						pDocMO.docId = docId
						pDocMO.visible = false
						pDocMO.version = 0
						if GlobDat.curDocId == docId {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocArrived),object:nil)}
					}

					var arDocFolders = Array(pDocMO.foldersList!)
					for (folderId,arrayDVD) in folderDocs
					{
						if let idx = arrayDVD.index(where:{$0.docId == docId})
						{
							pDocMO.addToFolder(folderId, Utils.getDateFromString(arrayDVD[idx].strDate), 0)
							if let idx2 = arDocFolders.index(where:{$0.folderId == folderId})
							{
								arDocFolders.remove(at: idx2)
							}
						}
					}
					for pFolderRec in arDocFolders
					{
						pDocMO.removeFromFoldersList(pFolderRec)
						moc.delete(pFolderRec)
					}

					if GlobDat.bDisableCheckDocumentVersion || (pDocMO.version < version) || self.shouldDownloadAttachments(pDocMO)// && ![Synchronizer_v3610 findAlreadyDownloadedDocInCurrentSynchronization:docId]
					{
						pDocMO.visible = false
						docsToDownload.append(pDocMO)
					}
					else
					{
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:docId)
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kAddToDownloadedDoc),object:docId)
					}
				}
				cdm.saveContext(moc)
			}
			cAllDocs = Int(docsToDownload.count)
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kGroup3DocCount),object:cAllDocs)
			var bCanceled = false
			if cAllDocs > 0
			{
				bCanceled = downloadDocuments(docsToDownload)
			}
			if !bCanceled {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocListLoaded),object:nil)}//for counting requests
		}
	}

	func processAcquDocumentParsed()
	{
		cDocsParsed += 1
		let str = String(format:"%d/%d",cDocsParsed,cAllDocs)
		let percent = cDocsParsed*100/cAllDocs
		Utils.runOnUI
		{
				SynchFuncs.synchProgress_updatePartialText(str)
				SynchFuncs.synchProgress_updatePartialPercentage(Int(percent))
		}
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kGroup3DocArrived),object:nil)
		Thread.sleep(forTimeInterval:0.1)//for progress updated incrementally
		#if LocalXML1
		Thread.sleep(forTimeInterval:1.0)
		#endif
	}

	func downloadDocuments(_ docsToDownload:[DocMO]) -> Bool
	{
		var bCanceled = false
		let filePath = Utils.getXMLFilePathFromResource("RequestDocumentAcqu")
		let requestDoc_FormatStr = try? String(contentsOfFile:filePath,encoding:.ascii)
		for pDocMO in docsToDownload
		{
			var data:Data? = nil 
			#if !LocalXML
			let requestStr = String(format:requestDoc_FormatStr!,pDocMO.docId)
			data = requestStr.data(using: String.Encoding.ascii)
			let url = Utils.createURL()
			#else
				let url = Utils.createURL(String(format:"AnswerFolderDocument%d",pDocMO.docId))
			#endif
			let docPortionDownloader = Downloader_FolderDoc(url,data,pDocMO)
			docPortionDownloader.start()
			bCanceled = !docPortionDownloader.isSuccess()
			processAcquDocumentParsed()
			if bCanceled {break}
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:pDocMO.docId)
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kAddToDownloadedDoc),object:pDocMO.docId)
		}
		return bCanceled
	}

	func shouldDownloadAttachments(_ pDocMO:DocMO) -> Bool
	{
		for pDocAtt in pDocMO.attSet!
		{
			if Utils.getFileSize(pDocAtt.fileId) != pDocAtt.fileSize {return true}
		}
		return false
	}
}
