//
//  AgreeHistoryMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension AgreeHistoryMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<AgreeHistoryMO>
	{
		return NSFetchRequest<AgreeHistoryMO>(entityName: "AgreeHistory");
	}

	@NSManaged public var result: NSNumber?
	@NSManaged public var dateFactEnd: Date?
	@NSManaged public var report: String?
	@NSManaged public var executor: ContactMO?

}
