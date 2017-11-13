//
//  ExecutionListMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension ExecutionListMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<ExecutionListMO>
	{
		return NSFetchRequest<ExecutionListMO>(entityName: "ExecutionList");
	}

	@NSManaged public var result: NSNumber?
	@NSManaged public var dateFactEnd: Date?
	@NSManaged public var report: String?
	@NSManaged public var datePlanEnd: Date?
	@NSManaged public var taskDescription: String?
	@NSManaged public var author: ContactMO?
	@NSManaged public var executor: ContactMO?

}
