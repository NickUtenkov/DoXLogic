//
//  ResolutionMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension ResolutionMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ResolutionMO>
	{
		return NSFetchRequest<ResolutionMO>(entityName: "Resolution");
	}

	@NSManaged public var executors: NSObject?
	@NSManaged public var datePlanEnd: Date?
	@NSManaged public var isTmp: Bool
	@NSManaged public var text: String?
	@NSManaged public var resolutionNumber: Int
	@NSManaged public var forwardId: Int
	@NSManaged public var author: ContactMO?
	@NSManaged public var responsible: ContactMO?
	@NSManaged public var executorsSet: Set<ContactMO>?
	@NSManaged public var controller: ContactMO?

}

// MARK: Generated accessors for executorsSet
extension ResolutionMO {

    @objc(addExecutorsSetObject:)
    @NSManaged public func addToExecutorsSet(_ value: ContactMO)

    @objc(removeExecutorsSetObject:)
    @NSManaged public func removeFromExecutorsSet(_ value: ContactMO)

    @objc(addExecutorsSet:)
    @NSManaged public func addToExecutorsSet(_ values: NSSet)

    @objc(removeExecutorsSet:)
    @NSManaged public func removeFromExecutorsSet(_ values: NSSet)

}
