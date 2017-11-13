//
//  AcquOperationMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by Nick Utenkov on 19/12/16.
//  Copyright © 2016 Nick Utenkov. All rights reserved.
//

import Foundation
import CoreData


extension AcquOperationMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<AcquOperationMO>
	{
		return NSFetchRequest<AcquOperationMO>(entityName: "AcquaintanceOperation");
	}

	@NSManaged public var folderId: Int
	@NSManaged public var order: Int
	@NSManaged public var operationUID: String?
	@NSManaged public var operationType: Int
	@NSManaged public var docId: Int

}
