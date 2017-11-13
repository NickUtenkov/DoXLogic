//
//  Downloader_Autotext.swift
//  DoXSw
//
//  Created by Nick Utenkov on 03/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_Autotext : DataDownloader
{
	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Autotext".localized
		#if !LocalXML
			dlURL = Utils.createURL()
			let filePath = Utils.getXMLFilePathFromResource("RequestAutotext")
			m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
			dlURL = Utils.createURL("AnswerAutotext")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getAutotexts"]
		{
			let succ = XMLFuncs.getSuccessAttributeValue(elem)
			if succ == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Autotexts failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorLoggableDownload),object:errMessage)
				return
			}
			let cdm:CoreDataManager = CoreDataManager.sharedInstance
			let moc:NSManagedObjectContext = cdm.createWorkerContext()
			CorDatFuncs.removeAllAutotexts(moc)
			
			let items = elem.children.filter({ $0.name == "item" })
			for item in items
			{
				let attrs = item.attributes
				let record = (NSEntityDescription.insertNewObject(forEntityName: "Autotext", into: moc) as! AutotextMO)
				record.autoTextId = Int(attrs["id"]!)!
				record.operationUID = nil
				record.operationType = 0
				record.text = attrs["value"]
				let elemKind:AEXMLElement = item["kind"]
				let attrsKind = elemKind.attributes
				record.code = attrsKind["code"]
				record.parentCode = attrsKind["parentCode"]
			}
			cdm.saveContext(moc)
		}
	}
}
