//
//  AutotextMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension AutotextMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<AutotextMO>
	{
		return NSFetchRequest<AutotextMO>(entityName: "Autotext");
	}

	@NSManaged public var code: String?
	@NSManaged public var autoTextId: Int
	@NSManaged public var parentCode: String?
	@NSManaged public var operationUID: String?
	@NSManaged public var operationType: Int
	@NSManaged public var text: String?

}
