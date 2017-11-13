//
//  DocMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension DocMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<DocMO>
	{
		return NSFetchRequest<DocMO>(entityName: "Document");
   }

	@NSManaged public var haveBeenRead: Int
	@NSManaged public var docId: Int
	@NSManaged public var controlDate: Date?
	@NSManaged public var controlStateCode: Int
	@NSManaged public var linkedDocs: Array<DocLinkedMO>?
	@NSManaged public var docket: String?
	@NSManaged public var eclass: String?
	@NSManaged public var version: Int
	@NSManaged public var isSelected: Bool
	@NSManaged public var type: String?
	@NSManaged public var priority: Bool
	@NSManaged public var inRegistration: String?
	@NSManaged public var fullNameOfBClass: String?
	@NSManaged public var signatureHash: String?
	@NSManaged public var docTitle: String?
	@NSManaged public var inDate: Date?
	@NSManaged public var visible: Bool
	@NSManaged public var addresse: ContactMO?
	@NSManaged public var agreeHistory: Set<AgreeHistoryMO>?
	@NSManaged public var contact: ContactMO?
	@NSManaged public var senders: Set<ContactMO>?
	@NSManaged public var executionList: Set<ExecutionListMO>?
	@NSManaged public var linkedDocSet: Set<DocLinkedMO>?
	@NSManaged public var tasks: Set<TaskUnprocessed>?
	@NSManaged public var correspondent: ContactMO?
	@NSManaged public var recepients: Set<ContactMO>?
	@NSManaged public var foldersList: Set<DocFolderMO>?
	@NSManaged public var author: ContactMO?
	@NSManaged public var attSet: Set<DocContentMO>?

}

// MARK: Generated accessors for agreeHistory
extension DocMO {

    @objc(addAgreeHistoryObject:)
    @NSManaged public func addToAgreeHistory(_ value: AgreeHistoryMO)

    @objc(removeAgreeHistoryObject:)
    @NSManaged public func removeFromAgreeHistory(_ value: AgreeHistoryMO)

    @objc(addAgreeHistory:)
    @NSManaged public func addToAgreeHistory(_ values: NSSet)

    @objc(removeAgreeHistory:)
    @NSManaged public func removeFromAgreeHistory(_ values: NSSet)

}

// MARK: Generated accessors for senders
extension DocMO {

    @objc(addSendersObject:)
    @NSManaged public func addToSenders(_ value: ContactMO)

    @objc(removeSendersObject:)
    @NSManaged public func removeFromSenders(_ value: ContactMO)

    @objc(addSenders:)
    @NSManaged public func addToSenders(_ values: NSSet)

    @objc(removeSenders:)
    @NSManaged public func removeFromSenders(_ values: NSSet)

}

// MARK: Generated accessors for executionList
extension DocMO {

    @objc(addExecutionListObject:)
    @NSManaged public func addToExecutionList(_ value: ExecutionListMO)

    @objc(removeExecutionListObject:)
    @NSManaged public func removeFromExecutionList(_ value: ExecutionListMO)

    @objc(addExecutionList:)
    @NSManaged public func addToExecutionList(_ values: NSSet)

    @objc(removeExecutionList:)
    @NSManaged public func removeFromExecutionList(_ values: NSSet)

}

// MARK: Generated accessors for linkedDocSet
extension DocMO {

    @objc(addLinkedDocSetObject:)
    @NSManaged public func addToLinkedDocSet(_ value: DocLinkedMO)

    @objc(removeLinkedDocSetObject:)
    @NSManaged public func removeFromLinkedDocSet(_ value: DocLinkedMO)

    @objc(addLinkedDocSet:)
    @NSManaged public func addToLinkedDocSet(_ values: NSSet)

    @objc(removeLinkedDocSet:)
    @NSManaged public func removeFromLinkedDocSet(_ values: NSSet)

}

// MARK: Generated accessors for tasks
extension DocMO {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskUnprocessed)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskUnprocessed)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

// MARK: Generated accessors for recepients
extension DocMO {

    @objc(addRecepientsObject:)
    @NSManaged public func addToRecepients(_ value: ContactMO)

    @objc(removeRecepientsObject:)
    @NSManaged public func removeFromRecepients(_ value: ContactMO)

    @objc(addRecepients:)
    @NSManaged public func addToRecepients(_ values: NSSet)

    @objc(removeRecepients:)
    @NSManaged public func removeFromRecepients(_ values: NSSet)

}

// MARK: Generated accessors for foldersList
extension DocMO {

    @objc(addFoldersListObject:)
    @NSManaged public func addToFoldersList(_ value: DocFolderMO)

    @objc(removeFoldersListObject:)
    @NSManaged public func removeFromFoldersList(_ value: DocFolderMO)

    @objc(addFoldersList:)
    @NSManaged public func addToFoldersList(_ values: NSSet)

    @objc(removeFoldersList:)
    @NSManaged public func removeFromFoldersList(_ values: NSSet)

}

// MARK: Generated accessors for attSet
extension DocMO {

    @objc(addAttSetObject:)
    @NSManaged public func addToAttSet(_ value: DocContentMO)

    @objc(removeAttSetObject:)
    @NSManaged public func removeFromAttSet(_ value: DocContentMO)

    @objc(addAttSet:)
    @NSManaged public func addToAttSet(_ values: NSSet)

    @objc(removeAttSet:)
    @NSManaged public func removeFromAttSet(_ values: NSSet)

}
