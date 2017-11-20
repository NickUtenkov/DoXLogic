//
//  CorDatFuncs.swift
//  DoXSw
//
//  Created by Nick Utenkov on 25/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class CorDatFuncs
{
	static func addContact(_ moc:NSManagedObjectContext,_ req:NSFetchRequest<ContactMO>,_ elem:AEXMLElement,_ bIsFavorite:Bool,_ bIsAffilate:Bool) -> ContactMO
	{
		var record:ContactMO? = nil

		var attrs = elem.attributes
		let employeeId = Int(attrs["id"]!)!
		let predic:NSPredicate = .init(format:"employeeId==%d",employeeId)
		req.predicate = predic
		var bInsert = false

		moc.performAndWait
		{
			let recordTmp:ContactMO? = try! moc.fetch(req).first
			if recordTmp != nil
			{
				record = recordTmp!
			}
			else
			{
				bInsert = true
				record = (NSEntityDescription.insertNewObject(forEntityName: "Contact", into: moc) as! ContactMO)
				record!.employeeId = employeeId
				record!.favorite = bIsFavorite
				record!.isAffilate = bIsAffilate
			}
		}

		record!.name = attrs["name"]
		record!.position = attrs["position"]
		record!.bclass = attrs["bclass"]

		if !bInsert
		{
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteContact),object:employeeId)
			if !record!.favorite && bIsFavorite {record!.favorite = bIsFavorite}
			if bIsFavorite {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteFavorite),object:employeeId)}
			if !record!.isAffilate && bIsAffilate {record!.isAffilate = bIsAffilate}
			if bIsAffilate {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteAffilate),object:employeeId)}
		}
		return record!
	}

	static func fetchOneRecord<T:NSManagedObject>(_ predic:NSPredicate,_ req:NSFetchRequest<T>,_ moc:NSManagedObjectContext) -> T?
	{
		var record:T? = nil
		req.predicate = predic
		moc.performAndWait
		{
			record = try! moc.fetch(req).first
		}
		return record
	}

	static func updateLinkedObjects(_ items:[AEXMLElement],_ pTask:TaskUnprocessed,_ relObjects:Set<LinkedMO>,_ selectorAdd:Selector,_ selectorRemove:Selector,_ idxAction:Int)
	{
		var arObjectsBefore = Array(relObjects)
		var linkedRec:LinkedMO? = nil
		let moc = pTask.managedObjectContext!
		for item in items
		{
			let attrs = item.attributes
			let linkedId = Int(attrs["id"]!)!
			let linkedName = attrs["name"]
			let linkedSH = attrs["signatureHash"]

			let idx = arObjectsBefore.index(where:{$0.linkedId == linkedId})
			if idx == nil
			{
				linkedRec = NSEntityDescription.insertNewObject(forEntityName: "LinkedObject", into: moc) as? LinkedMO
				linkedRec!.linkedId = linkedId
				pTask.perform(selectorAdd,on:Thread.current ,with:linkedRec,waitUntilDone:true)
				if idxAction == 1
				{
					var pDocMO:DocMO? = nil
					pDocMO = fetchOneRecord(NSPredicate(format:"docId==%d",linkedId),DocMO.fetchRequest(),moc)
					if pDocMO == nil
					{
						pDocMO = NSEntityDescription.insertNewObject(forEntityName: "Document", into: moc) as? DocMO
						pDocMO!.docId = linkedId
						pDocMO!.docTitle = linkedName;//in case doc not arrived ?!
						pDocMO!.visible = false
						pDocMO!.version = 0
						if GlobDat.curDocId == linkedId
						{
							NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocArrived),object:nil)
						}
					}
					linkedRec!.document = pDocMO
				}
				else if idxAction == 2
				{
					var pDocAtt:DocContentMO? = nil
					pDocAtt = fetchOneRecord(NSPredicate(format:"fileId==%d",linkedId),DocContentMO.fetchRequest(),moc)
					if pDocAtt == nil
					{
						pDocAtt = NSEntityDescription.insertNewObject(forEntityName: "DocContent", into: moc) as? DocContentMO
						pDocAtt!.fileId = linkedId
						pDocAtt!.fileName = linkedName//in case attachment not arrived(too big size for example)
					}
					linkedRec!.file = pDocAtt
				}
			}
			else
			{
				linkedRec = arObjectsBefore[idx!]
				arObjectsBefore.remove(at: idx!)
			}
			linkedRec!.linkedName = linkedName
			linkedRec!.linkedSignatureHash = linkedSH
		}
		for linkedRec in arObjectsBefore
		{
			pTask.perform(selectorRemove,on:Thread.current ,with:linkedRec,waitUntilDone:true)
			moc.delete(linkedRec)
		}
	}

	static func parseAgreeHistory(_ pMO:NSManagedObject,_ moSet:Set<AgreeHistoryMO>,_ selAdd:Selector,_ items:[AEXMLElement],_ requestContact:NSFetchRequest<ContactMO>)
	{
		let moc:NSManagedObjectContext = pMO.managedObjectContext!
		for item in items
		{
			let attrs = item.attributes
			let pRec:AgreeHistoryMO = NSEntityDescription.insertNewObject(forEntityName: "AgreeHistory", into: moc) as! AgreeHistoryMO
			if let executor = item.children.filter({ $0.name == "author" }).first
			{
				pRec.executor = CorDatFuncs.addContact(moc, requestContact, executor, false, false)
			}
			pRec.dateFactEnd = Utils.getDateFromString(attrs["dateFactEnd"])
			pRec.report = attrs["report"]
			if let strResult = attrs["result"]
			{
				pRec.result = strResult.bool as NSNumber?
			}
			pMO.perform(selAdd,on:Thread.current ,with:pRec,waitUntilDone:true)
		}
	}

	static func addError(_ errStr:String?)
	{
		if errStr != nil
		{
			let moc = CoreDataManager.sharedInstance.createPrivateContext()
			let pRec = NSEntityDescription.insertNewObject(forEntityName: "Errors", into: moc) as! ErrorMO
			pRec.Text = errStr!
			pRec.Date = Date()
			CoreDataManager.sharedInstance.savePrivateContext(moc)
		}
	}

	static func removeAllAutotexts(_ moc:NSManagedObjectContext)
	{
		if let model = moc.persistentStoreCoordinator?.managedObjectModel
		{
			if let req:NSFetchRequest<AutotextMO> = model.fetchRequestTemplate(forName:"AutotextNotModified") as! NSFetchRequest<AutotextMO>?
			{
				moc.performAndWait
				{
					if let records:[AutotextMO] = try? moc.fetch(req)
					{
						for record in records {moc.delete(record)}//may be use NSBatchDeleteRequest ?!
					}
				}
			}
		}
	}

	static func removeRelationshipObjects<T:NSManagedObject>(_ pObjToDeleteFrom:NSManagedObject,_ relObjects:Set<T>,_ selector:Selector,_ bDeleteRec:Bool)
	{
		let arObjects = Array(relObjects)
		let ctx:NSManagedObjectContext = pObjToDeleteFrom.managedObjectContext!
		for pObject in arObjects
		{
			pObjToDeleteFrom.perform(selector,on:Thread.current ,with:pObject,waitUntilDone:true)
			if bDeleteRec {ctx.delete(pObject)}
		}
	}
}
