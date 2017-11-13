//
//  TaskProcessed+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension TaskProcessed
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<TaskProcessed>
	{
		return NSFetchRequest<TaskProcessed>(entityName: "TaskProcessed");
	}

	@NSManaged public var taskSignatureDT: String?
	@NSManaged public var resolutionReport: String?
	@NSManaged public var report: String?
	@NSManaged public var documentSignatureDT: String?
	@NSManaged public var docSign: String?
	@NSManaged public var executeType: Int
	@NSManaged public var state: String?
	@NSManaged public var taskSign: String?
	@NSManaged public var certificateHash: String?
	@NSManaged public var uploadDate: Date?
	@NSManaged public var result: NSNumber?
	@NSManaged public var outputOrReportFiles: NSObject?
	@NSManaged public var comment: String?
	@NSManaged public var taskId: Int
	@NSManaged public var childTasksSet: Set<ChildTaskMO>?
	@NSManaged public var outputFilesUpdated: Set<LinkedMO>?
	@NSManaged public var controller: ContactMO?
	@NSManaged public var resolutionsSet: Set<ResolutionMO>?
	@NSManaged public var outputDocumentsUpdated: Set<LinkedMO>?
	@NSManaged public var executor: ContactMO?
	@NSManaged public var reportFilesUpdated: Set<LinkedMO>?

}

// MARK: Generated accessors for childTasksSet
extension TaskProcessed {

    @objc(addChildTasksSetObject:)
    @NSManaged public func addToChildTasksSet(_ value: ChildTaskMO)

    @objc(removeChildTasksSetObject:)
    @NSManaged public func removeFromChildTasksSet(_ value: ChildTaskMO)

    @objc(addChildTasksSet:)
    @NSManaged public func addToChildTasksSet(_ values: NSSet)

    @objc(removeChildTasksSet:)
    @NSManaged public func removeFromChildTasksSet(_ values: NSSet)

}

// MARK: Generated accessors for outputFilesUpdated
extension TaskProcessed {

    @objc(addOutputFilesUpdatedObject:)
    @NSManaged public func addToOutputFilesUpdated(_ value: LinkedMO)

    @objc(removeOutputFilesUpdatedObject:)
    @NSManaged public func removeFromOutputFilesUpdated(_ value: LinkedMO)

    @objc(addOutputFilesUpdated:)
    @NSManaged public func addToOutputFilesUpdated(_ values: NSSet)

    @objc(removeOutputFilesUpdated:)
    @NSManaged public func removeFromOutputFilesUpdated(_ values: NSSet)

}

// MARK: Generated accessors for resolutionsSet
extension TaskProcessed {

    @objc(addResolutionsSetObject:)
    @NSManaged public func addToResolutionsSet(_ value: ResolutionMO)

    @objc(removeResolutionsSetObject:)
    @NSManaged public func removeFromResolutionsSet(_ value: ResolutionMO)

    @objc(addResolutionsSet:)
    @NSManaged public func addToResolutionsSet(_ values: NSSet)

    @objc(removeResolutionsSet:)
    @NSManaged public func removeFromResolutionsSet(_ values: NSSet)

}

// MARK: Generated accessors for outputDocumentsUpdated
extension TaskProcessed {

    @objc(addOutputDocumentsUpdatedObject:)
    @NSManaged public func addToOutputDocumentsUpdated(_ value: LinkedMO)

    @objc(removeOutputDocumentsUpdatedObject:)
    @NSManaged public func removeFromOutputDocumentsUpdated(_ value: LinkedMO)

    @objc(addOutputDocumentsUpdated:)
    @NSManaged public func addToOutputDocumentsUpdated(_ values: NSSet)

    @objc(removeOutputDocumentsUpdated:)
    @NSManaged public func removeFromOutputDocumentsUpdated(_ values: NSSet)

}

// MARK: Generated accessors for reportFilesUpdated
extension TaskProcessed {

    @objc(addReportFilesUpdatedObject:)
    @NSManaged public func addToReportFilesUpdated(_ value: LinkedMO)

    @objc(removeReportFilesUpdatedObject:)
    @NSManaged public func removeFromReportFilesUpdated(_ value: LinkedMO)

    @objc(addReportFilesUpdated:)
    @NSManaged public func addToReportFilesUpdated(_ values: NSSet)

    @objc(removeReportFilesUpdated:)
    @NSManaged public func removeFromReportFilesUpdated(_ values: NSSet)

}
