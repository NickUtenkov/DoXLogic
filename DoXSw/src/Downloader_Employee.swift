//
//  Downloader_Employee.swift
//  DoXSw
//
//  Created by Nick Utenkov on 24/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_Employee : DataDownloader
{
	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Employee".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestContact")
		m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
		dlURL = Utils.createURL("AnswerContact")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getContacts"]
		{
			let succ = XMLFuncs.getSuccessAttributeValue(elem)
			if succ == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Contacts failed"}
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
					_ = CorDatFuncs.addContact(moc, req, item, true, false)
				}
				cdm.saveContext(moc)
			}
		}
	}
}
