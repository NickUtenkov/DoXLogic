//
//  TaskUnprocessed+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

extension TaskUnprocessed
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<TaskUnprocessed>
	{
		return NSFetchRequest<TaskUnprocessed>(entityName: "Task");
	}

	@NSManaged public var datePlanEnd: Date?
	@NSManaged public var state: String?
	@NSManaged public var dateDeliver: Date?
	@NSManaged public var reworkDescription: String?
	@NSManaged public var shouldSignTask: Bool
	@NSManaged public var taskDescription: String?
	@NSManaged public var docId: Int
	@NSManaged public var autoComplete: Bool
	@NSManaged public var acceptExecution: Bool
	@NSManaged public var dateFactEnd: Date?
	@NSManaged public var shouldSignDocument: Bool
	@NSManaged public var fullNameOfBClass: String?
	@NSManaged public var name: String?
	@NSManaged public var consolidated: Bool
	@NSManaged public var taskId: Int
	@NSManaged public var result: NSNumber?
	@NSManaged public var canComplete: Bool
	@NSManaged public var operationUID: String?
	@NSManaged public var report: String?
	@NSManaged public var eclassId: Int
	@NSManaged public var reworkReason: String?
	@NSManaged public var author: ContactMO?
	@NSManaged public var inputDocuments: Set<LinkedMO>?
	@NSManaged public var reportFiles: Set<LinkedMO>?
	@NSManaged public var outputFiles: Set<LinkedMO>?
	@NSManaged public var coexecutor: ContactMO?
	@NSManaged public var resolutionsSet: Set<ResolutionMO>?
	@NSManaged public var childTasksSet: Set<ChildTaskMO>?
	@NSManaged public var outputDocSet: Set<LinkedMO>?
	@NSManaged public var controller: ContactMO?
	@NSManaged public var taskProcessed: TaskProcessed?
	@NSManaged public var executor: ContactMO?
	@NSManaged public var inputFiles: Set<LinkedMO>?

}

// MARK: Generated accessors for inputDocuments
extension TaskUnprocessed {

    @objc(addInputDocumentsObject:)
    @NSManaged public func addToInputDocuments(_ value: LinkedMO)

    @objc(removeInputDocumentsObject:)
    @NSManaged public func removeFromInputDocuments(_ value: LinkedMO)

    @objc(addInputDocuments:)
    @NSManaged public func addToInputDocuments(_ values: NSSet)

    @objc(removeInputDocuments:)
    @NSManaged public func removeFromInputDocuments(_ values: NSSet)

}

// MARK: Generated accessors for reportFiles
extension TaskUnprocessed {

    @objc(addReportFilesObject:)
    @NSManaged public func addToReportFiles(_ value: LinkedMO)

    @objc(removeReportFilesObject:)
    @NSManaged public func removeFromReportFiles(_ value: LinkedMO)

    @objc(addReportFiles:)
    @NSManaged public func addToReportFiles(_ values: NSSet)

    @objc(removeReportFiles:)
    @NSManaged public func removeFromReportFiles(_ values: NSSet)

}

// MARK: Generated accessors for outputFiles
extension TaskUnprocessed {

    @objc(addOutputFilesObject:)
    @NSManaged public func addToOutputFiles(_ value: LinkedMO)

    @objc(removeOutputFilesObject:)
    @NSManaged public func removeFromOutputFiles(_ value: LinkedMO)

    @objc(addOutputFiles:)
    @NSManaged public func addToOutputFiles(_ values: NSSet)

    @objc(removeOutputFiles:)
    @NSManaged public func removeFromOutputFiles(_ values: NSSet)

}

// MARK: Generated accessors for resolutionsSet
extension TaskUnprocessed {

    @objc(addResolutionsSetObject:)
    @NSManaged public func addToResolutionsSet(_ value: ResolutionMO)

    @objc(removeResolutionsSetObject:)
    @NSManaged public func removeFromResolutionsSet(_ value: ResolutionMO)

    @objc(addResolutionsSet:)
    @NSManaged public func addToResolutionsSet(_ values: NSSet)

    @objc(removeResolutionsSet:)
    @NSManaged public func removeFromResolutionsSet(_ values: NSSet)

}

// MARK: Generated accessors for childTasksSet
extension TaskUnprocessed {

    @objc(addChildTasksSetObject:)
    @NSManaged public func addToChildTasksSet(_ value: ChildTaskMO)

    @objc(removeChildTasksSetObject:)
    @NSManaged public func removeFromChildTasksSet(_ value: ChildTaskMO)

    @objc(addChildTasksSet:)
    @NSManaged public func addToChildTasksSet(_ values: NSSet)

    @objc(removeChildTasksSet:)
    @NSManaged public func removeFromChildTasksSet(_ values: NSSet)

}

// MARK: Generated accessors for outputDocSet
extension TaskUnprocessed {

    @objc(addOutputDocSetObject:)
    @NSManaged public func addToOutputDocSet(_ value: LinkedMO)

    @objc(removeOutputDocSetObject:)
    @NSManaged public func removeFromOutputDocSet(_ value: LinkedMO)

    @objc(addOutputDocSet:)
    @NSManaged public func addToOutputDocSet(_ values: NSSet)

    @objc(removeOutputDocSet:)
    @NSManaged public func removeFromOutputDocSet(_ values: NSSet)

}

// MARK: Generated accessors for inputFiles
extension TaskUnprocessed {

    @objc(addInputFilesObject:)
    @NSManaged public func addToInputFiles(_ value: LinkedMO)

    @objc(removeInputFilesObject:)
    @NSManaged public func removeFromInputFiles(_ value: LinkedMO)

    @objc(addInputFiles:)
    @NSManaged public func addToInputFiles(_ values: NSSet)

    @objc(removeInputFiles:)
    @NSManaged public func removeFromInputFiles(_ values: NSSet)

}
