//
//  TaskUnprocessed+CoreDataClass.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

@objc(TaskUnprocessed)
public class TaskUnprocessed: NSManagedObject
{
	lazy var displayEClassId:Int =
	{[unowned self] in
		var _displayEClassId = self.eclassId
		if ((self.eclassId == GlobDat.eClass_WorkflowReferencesFormalTask) && GlobDat.bIsBoss)
		{
			_displayEClassId = GlobDat.eClass_DocflowReferencesReviewDocument
		}
		if self.acceptExecution {_displayEClassId = GlobDat.eClass_AcceptExecution}
		return _displayEClassId
	}()

	func resetOutputOrReportFiles()
	{
		//outputOrReportFiles = []
	}

	func deleteProcessedTask(_ bSaveCtx:Bool)
	{
		if self.taskProcessed != nil
		{
			let moc = managedObjectContext!
			moc.delete(taskProcessed!)
			taskProcessed = nil
			if bSaveCtx {CoreDataManager.sharedInstance.saveContext(moc)}
		}
	}
}
