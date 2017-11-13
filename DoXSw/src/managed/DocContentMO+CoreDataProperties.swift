//
//  DocContentMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension DocContentMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<DocContentMO>
	{
		return NSFetchRequest<DocContentMO>(entityName: "DocContent");
	}

	@NSManaged public var fileHash: String?
	@NSManaged public var rotation: Float
	@NSManaged public var fileName: String?
	@NSManaged public var fileSize: UInt64
	@NSManaged public var mime: String?
	@NSManaged public var nOrder: Int
	@NSManaged public var fileId: Int
	@NSManaged public var scrollPos: Float
	@NSManaged public var isSelected: Bool
	@NSManaged public var docFiles: NSSet?
	@NSManaged public var childReportFiles: NSSet?
	@NSManaged public var docLinkedFiles: NSSet?
	@NSManaged public var childOutputFiles: NSSet?

}

// MARK: Generated accessors for docFiles
extension DocContentMO {

    @objc(addDocFilesObject:)
    @NSManaged public func addToDocFiles(_ value: DocMO)

    @objc(removeDocFilesObject:)
    @NSManaged public func removeFromDocFiles(_ value: DocMO)

    @objc(addDocFiles:)
    @NSManaged public func addToDocFiles(_ values: NSSet)

    @objc(removeDocFiles:)
    @NSManaged public func removeFromDocFiles(_ values: NSSet)

}

// MARK: Generated accessors for childReportFiles
extension DocContentMO {

    @objc(addChildReportFilesObject:)
    @NSManaged public func addToChildReportFiles(_ value: ChildTaskMO)

    @objc(removeChildReportFilesObject:)
    @NSManaged public func removeFromChildReportFiles(_ value: ChildTaskMO)

    @objc(addChildReportFiles:)
    @NSManaged public func addToChildReportFiles(_ values: NSSet)

    @objc(removeChildReportFiles:)
    @NSManaged public func removeFromChildReportFiles(_ values: NSSet)

}

// MARK: Generated accessors for docLinkedFiles
extension DocContentMO {

    @objc(addDocLinkedFilesObject:)
    @NSManaged public func addToDocLinkedFiles(_ value: DocLinkedMO)

    @objc(removeDocLinkedFilesObject:)
    @NSManaged public func removeFromDocLinkedFiles(_ value: DocLinkedMO)

    @objc(addDocLinkedFiles:)
    @NSManaged public func addToDocLinkedFiles(_ values: NSSet)

    @objc(removeDocLinkedFiles:)
    @NSManaged public func removeFromDocLinkedFiles(_ values: NSSet)

}

// MARK: Generated accessors for childOutputFiles
extension DocContentMO {

    @objc(addChildOutputFilesObject:)
    @NSManaged public func addToChildOutputFiles(_ value: ChildTaskMO)

    @objc(removeChildOutputFilesObject:)
    @NSManaged public func removeFromChildOutputFiles(_ value: ChildTaskMO)

    @objc(addChildOutputFiles:)
    @NSManaged public func addToChildOutputFiles(_ values: NSSet)

    @objc(removeChildOutputFiles:)
    @NSManaged public func removeFromChildOutputFiles(_ values: NSSet)

}
