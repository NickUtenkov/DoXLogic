//
//  Downloader_Affilate.swift
//  DoXSw
//
//  Created by Nick Utenkov on 25/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_Affilate : DataDownloader
{
	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Affilate".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestAffilate")
		m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
		dlURL = Utils.createURL("AnswerAffilate")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getAffilates"]
		{
			let succ = XMLFuncs.getSuccessAttributeValue(elem)
			if succ == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Affilates failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorLoggableDownload),object:errMessage)
				return
			}
			let cdm:CoreDataManager = CoreDataManager.sharedInstance
			let moc = cdm.createWorkerContext()
			moc.performAndWait
			{
				let req:NSFetchRequest<ContactMO> = ContactMO.fetchRequest()
				
				let items = elem.children.filter({ $0.name == "item" })
				for item in items
				{
					let node:AEXMLElement = item["contactTo"]
					_ = CorDatFuncs.addContact(moc, req, node, false, true)
				}
				cdm.saveContext(moc)
			}
		}
	}
}
