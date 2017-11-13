//
//  ErrorMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by Nick Utenkov on 02/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import CoreData


extension ErrorMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<NSManagedObject>
	{
		return NSFetchRequest<NSManagedObject>(entityName: "Errors");
	}

	@NSManaged public var Date: Date
	@NSManaged public var Text: String

}
