//
//  Downloader_FolderDocIds.swift
//  DoXSw
//
//  Created by Nick Utenkov on 03/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation

struct DocVersionDate
{
	var docId:Int
	var version:Int
	var strDate:String

	init(_ docId1:Int,_ version1:Int,_ strDate1:String)
	{
		docId = docId1
		version = version1
		strDate = strDate1
	}
}

final class Downloader_FolderDocIds : DataDownloader
{
	var m_FolderId = 0
	var arDVD:[DocVersionDate] = []

	init(_ folderId:Int)
	{
		m_FolderId = folderId
	}

	override func main()
	{
		if isCancelled {return}
		#if !LocalXML
			dlURL = Utils.createURL()
			let filePath = Utils.getXMLFilePathFromResource("RequestFolderDocumentsIds")
			let str = try? String(contentsOfFile:filePath,encoding:.ascii)
			let requestDoc = String(format:str!,m_FolderId)
			m_dataXML = requestDoc.data(using:.ascii)
		#else
			dlURL = Utils.createURL(String(format:"AnswerFolderDocumentsId%d",m_FolderId))
		#endif
		m_requestName = "RequestName_AcquaintanceFolderDocuments".localized
		//print("Downloader_FolderDocIds",m_FolderId)
		super.main()
	}

	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getFolderDocumentsId"]
		{
			if XMLFuncs.getSuccessAttributeValue(elem) == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Folder Documents Ids failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical),object:errMessage)
				return
			}
			let docItems = elem.children.filter({ $0.name == "item" })
			for docItem in docItems
			{
				if let docElem = docItem.children.filter({ $0.name == "document" }).first
				{
					let attrs = docElem.attributes
					let docId = Int(attrs["id"]!)!
					let version = XMLFuncs.getVersionFromAttrs(attrs)
					let aDVD = DocVersionDate(docId,version,docItem.attributes["sendDT"]!)
					arDVD.append(aDVD)
				}
			}
		}
	}

	func getArray() -> [DocVersionDate]
	{
		return arDVD
	}
}
