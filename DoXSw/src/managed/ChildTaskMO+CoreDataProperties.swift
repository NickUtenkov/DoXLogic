//
//  ChildTaskMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension ChildTaskMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ChildTaskMO>
	{
		return NSFetchRequest<ChildTaskMO>(entityName: "ChildTask");
	}

	@NSManaged public var dateFactEnd: Date?
	@NSManaged public var approved: NSNumber?
	@NSManaged public var taskId: Int
	@NSManaged public var datePlanEnd: Date?
	@NSManaged public var report: String?
	@NSManaged public var files: Array<DocContentMO>?
	@NSManaged public var isResTextSelected: Bool
	@NSManaged public var state: String?
	@NSManaged public var isCanReviewState: Bool
	@NSManaged public var rework: NSNumber?
	@NSManaged public var isTmp: Bool
	@NSManaged public var comment: String?
	@NSManaged public var taskDescription: String?
	@NSManaged public var isCanReview: Bool
	@NSManaged public var executorsSet: Set<ContactMO>?
	@NSManaged public var outputFiles: Set<DocContentMO>?
	@NSManaged public var docSet: Set<DocMO>?
	@NSManaged public var controller: ContactMO?
	@NSManaged public var responsible: ContactMO?
	@NSManaged public var reportFiles: Set<DocContentMO>?
	@NSManaged public var author: ContactMO?

}

// MARK: Generated accessors for executorsSet
extension ChildTaskMO {

    @objc(addExecutorsSetObject:)
    @NSManaged public func addToExecutorsSet(_ value: ContactMO)

    @objc(removeExecutorsSetObject:)
    @NSManaged public func removeFromExecutorsSet(_ value: ContactMO)

    @objc(addExecutorsSet:)
    @NSManaged public func addToExecutorsSet(_ values: NSSet)

    @objc(removeExecutorsSet:)
    @NSManaged public func removeFromExecutorsSet(_ values: NSSet)

}

// MARK: Generated accessors for outputFiles
extension ChildTaskMO {

    @objc(addOutputFilesObject:)
    @NSManaged public func addToOutputFiles(_ value: DocContentMO)

    @objc(removeOutputFilesObject:)
    @NSManaged public func removeFromOutputFiles(_ value: DocContentMO)

    @objc(addOutputFiles:)
    @NSManaged public func addToOutputFiles(_ values: NSSet)

    @objc(removeOutputFiles:)
    @NSManaged public func removeFromOutputFiles(_ values: NSSet)

}

// MARK: Generated accessors for docSet
extension ChildTaskMO {

    @objc(addDocSetObject:)
    @NSManaged public func addToDocSet(_ value: DocMO)

    @objc(removeDocSetObject:)
    @NSManaged public func removeFromDocSet(_ value: DocMO)

    @objc(addDocSet:)
    @NSManaged public func addToDocSet(_ values: NSSet)

    @objc(removeDocSet:)
    @NSManaged public func removeFromDocSet(_ values: NSSet)

}

// MARK: Generated accessors for reportFiles
extension ChildTaskMO {

    @objc(addReportFilesObject:)
    @NSManaged public func addToReportFiles(_ value: DocContentMO)

    @objc(removeReportFilesObject:)
    @NSManaged public func removeFromReportFiles(_ value: DocContentMO)

    @objc(addReportFiles:)
    @NSManaged public func addToReportFiles(_ values: NSSet)

    @objc(removeReportFiles:)
    @NSManaged public func removeFromReportFiles(_ values: NSSet)

}
