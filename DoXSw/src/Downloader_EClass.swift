//
//  Downloader_EClass.swift
//  DoXSw
//
//  Created by Nick Utenkov on 24/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_EClass : DataDownloader
{
	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_EClass".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestEClass2")
		m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
		dlURL = Utils.createURL("AnswerEClass")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}

	override func parse(_ doc:AEXMLDocument?)
	{
		if let elems:[AEXMLElement] = doc?.root["body"].children.filter({ $0.name == "getEClasses" })
		{
			var cNodes = 0,cGoodNodes = 0
			let cdm:CoreDataManager = CoreDataManager.sharedInstance
			let moc = cdm.createWorkerContext()
			let req:NSFetchRequest<EClassMO> = EClassMO.fetchRequest()

			for elem in elems
			{
				cNodes += 1
				let succ = XMLFuncs.getSuccessAttributeValue(elem)
				if succ != 0 {cGoodNodes += 1}
				else {continue}

				let items:[AEXMLElement] = elem.children.filter({ $0.name == "item" })
				for item in items
				{
					let attrs = item.attributes
					let recId = Int(attrs["id"]!)!

					let predic:NSPredicate = .init(format:"eclassId==%d",recId)
					req.predicate = predic

					moc.performAndWait
					{
						if let eClassRecords:[EClassMO] = try? moc.fetch(req)
						{
							if eClassRecords.count == 0
							{
								let eClassRec = NSEntityDescription.insertNewObject(forEntityName: "EClass", into: moc) as! EClassMO
								eClassRec.eclassId = recId
								eClassRec.name = attrs["nls_name"]
								eClassRec.fullName = attrs["fullName"]
							}
						}
					}
				}
			}
			cdm.saveContext(moc)
			if cGoodNodes > 0 {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kEClassLoaded),object:nil)}
			if (cNodes == 0) || (cNodes != cGoodNodes)
			{
				let str = (cGoodNodes == 0) ? GlobDat.kSynchErrorCritical : GlobDat.kSynchErrorLoggableDownload
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:str),object:"strNotAllEClassesLoaded".localized)
			}
		}
	}
}
