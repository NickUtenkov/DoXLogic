//
//  ContactMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension ContactMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ContactMO>
	{
		return NSFetchRequest<ContactMO>(entityName: "Contact");
	}

	@NSManaged public var isAffilate: Bool
	@NSManaged public var favorite: Bool
	@NSManaged public var bclass: String?
	@NSManaged public var position: String?
	@NSManaged public var employeeId: Int
	@NSManaged public var isSelected: Bool
	@NSManaged public var name: String?
	@NSManaged public var docSenders: NSSet?
	@NSManaged public var childTaskExecutors: NSSet?
	@NSManaged public var docLinkedRecepients: NSSet?
	@NSManaged public var resolutionExecutors: NSSet?
	@NSManaged public var docRecepients: NSSet?
	@NSManaged public var docLinkedSenders: NSSet?

}

// MARK: Generated accessors for docSenders
extension ContactMO {

    @objc(addDocSendersObject:)
    @NSManaged public func addToDocSenders(_ value: DocMO)

    @objc(removeDocSendersObject:)
    @NSManaged public func removeFromDocSenders(_ value: DocMO)

    @objc(addDocSenders:)
    @NSManaged public func addToDocSenders(_ values: NSSet)

    @objc(removeDocSenders:)
    @NSManaged public func removeFromDocSenders(_ values: NSSet)

}

// MARK: Generated accessors for childTaskExecutors
extension ContactMO {

    @objc(addChildTaskExecutorsObject:)
    @NSManaged public func addToChildTaskExecutors(_ value: ChildTaskMO)

    @objc(removeChildTaskExecutorsObject:)
    @NSManaged public func removeFromChildTaskExecutors(_ value: ChildTaskMO)

    @objc(addChildTaskExecutors:)
    @NSManaged public func addToChildTaskExecutors(_ values: NSSet)

    @objc(removeChildTaskExecutors:)
    @NSManaged public func removeFromChildTaskExecutors(_ values: NSSet)

}

// MARK: Generated accessors for docLinkedRecepients
extension ContactMO {

    @objc(addDocLinkedRecepientsObject:)
    @NSManaged public func addToDocLinkedRecepients(_ value: DocLinkedMO)

    @objc(removeDocLinkedRecepientsObject:)
    @NSManaged public func removeFromDocLinkedRecepients(_ value: DocLinkedMO)

    @objc(addDocLinkedRecepients:)
    @NSManaged public func addToDocLinkedRecepients(_ values: NSSet)

    @objc(removeDocLinkedRecepients:)
    @NSManaged public func removeFromDocLinkedRecepients(_ values: NSSet)

}

// MARK: Generated accessors for resolutionExecutors
extension ContactMO {

    @objc(addResolutionExecutorsObject:)
    @NSManaged public func addToResolutionExecutors(_ value: ResolutionMO)

    @objc(removeResolutionExecutorsObject:)
    @NSManaged public func removeFromResolutionExecutors(_ value: ResolutionMO)

    @objc(addResolutionExecutors:)
    @NSManaged public func addToResolutionExecutors(_ values: NSSet)

    @objc(removeResolutionExecutors:)
    @NSManaged public func removeFromResolutionExecutors(_ values: NSSet)

}

// MARK: Generated accessors for docRecepients
extension ContactMO {

    @objc(addDocRecepientsObject:)
    @NSManaged public func addToDocRecepients(_ value: DocMO)

    @objc(removeDocRecepientsObject:)
    @NSManaged public func removeFromDocRecepients(_ value: DocMO)

    @objc(addDocRecepients:)
    @NSManaged public func addToDocRecepients(_ values: NSSet)

    @objc(removeDocRecepients:)
    @NSManaged public func removeFromDocRecepients(_ values: NSSet)

}

// MARK: Generated accessors for docLinkedSenders
extension ContactMO {

    @objc(addDocLinkedSendersObject:)
    @NSManaged public func addToDocLinkedSenders(_ value: DocLinkedMO)

    @objc(removeDocLinkedSendersObject:)
    @NSManaged public func removeFromDocLinkedSenders(_ value: DocLinkedMO)

    @objc(addDocLinkedSenders:)
    @NSManaged public func addToDocLinkedSenders(_ values: NSSet)

    @objc(removeDocLinkedSenders:)
    @NSManaged public func removeFromDocLinkedSenders(_ values: NSSet)

}
