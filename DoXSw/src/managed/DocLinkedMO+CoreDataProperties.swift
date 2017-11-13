//
//  DocLinkedMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension DocLinkedMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<DocLinkedMO>
	{
		return NSFetchRequest<DocLinkedMO>(entityName: "DocumentsLinked");
	}

	@NSManaged public var docId: Int
	@NSManaged public var controlDate: NSDate?
	@NSManaged public var controlStateCode: NSNumber?
	@NSManaged public var docket: String?
	@NSManaged public var eclass: String?
	@NSManaged public var inRegistration: String?
	@NSManaged public var version: Int
	@NSManaged public var priority: Int
	@NSManaged public var type: String?
	@NSManaged public var inDate: NSDate?
	@NSManaged public var fullNameOfBClass: String?
	@NSManaged public var docTitle: String?
	@NSManaged public var attachments: Array<DocContentMO>?
	@NSManaged public var executionList: NSObject?
	@NSManaged public var addresse: ContactMO?
	@NSManaged public var agreeHistory: NSSet?
	@NSManaged public var contact: ContactMO?
	@NSManaged public var docSet: NSSet?
	@NSManaged public var correspondent: ContactMO?
	@NSManaged public var senders: Set<ContactMO>?
	@NSManaged public var recepients: Set<ContactMO>?
	@NSManaged public var author: ContactMO?
	@NSManaged public var attSet: Set<DocContentMO>?

}

// MARK: Generated accessors for agreeHistory
extension DocLinkedMO {

    @objc(addAgreeHistoryObject:)
    @NSManaged public func addToAgreeHistory(_ value: AgreeHistoryMO)

    @objc(removeAgreeHistoryObject:)
    @NSManaged public func removeFromAgreeHistory(_ value: AgreeHistoryMO)

    @objc(addAgreeHistory:)
    @NSManaged public func addToAgreeHistory(_ values: NSSet)

    @objc(removeAgreeHistory:)
    @NSManaged public func removeFromAgreeHistory(_ values: NSSet)

}

// MARK: Generated accessors for docSet
extension DocLinkedMO {

    @objc(addDocSetObject:)
    @NSManaged public func addToDocSet(_ value: DocMO)

    @objc(removeDocSetObject:)
    @NSManaged public func removeFromDocSet(_ value: DocMO)

    @objc(addDocSet:)
    @NSManaged public func addToDocSet(_ values: NSSet)

    @objc(removeDocSet:)
    @NSManaged public func removeFromDocSet(_ values: NSSet)

}

// MARK: Generated accessors for senders
extension DocLinkedMO {

    @objc(addSendersObject:)
    @NSManaged public func addToSenders(_ value: ContactMO)

    @objc(removeSendersObject:)
    @NSManaged public func removeFromSenders(_ value: ContactMO)

    @objc(addSenders:)
    @NSManaged public func addToSenders(_ values: NSSet)

    @objc(removeSenders:)
    @NSManaged public func removeFromSenders(_ values: NSSet)

}

// MARK: Generated accessors for recepients
extension DocLinkedMO {

    @objc(addRecepientsObject:)
    @NSManaged public func addToRecepients(_ value: ContactMO)

    @objc(removeRecepientsObject:)
    @NSManaged public func removeFromRecepients(_ value: ContactMO)

    @objc(addRecepients:)
    @NSManaged public func addToRecepients(_ values: NSSet)

    @objc(removeRecepients:)
    @NSManaged public func removeFromRecepients(_ values: NSSet)

}

// MARK: Generated accessors for attSet
extension DocLinkedMO {

    @objc(addAttSetObject:)
    @NSManaged public func addToAttSet(_ value: DocContentMO)

    @objc(removeAttSetObject:)
    @NSManaged public func removeFromAttSet(_ value: DocContentMO)

    @objc(addAttSet:)
    @NSManaged public func addToAttSet(_ values: NSSet)

    @objc(removeAttSet:)
    @NSManaged public func removeFromAttSet(_ values: NSSet)

}
