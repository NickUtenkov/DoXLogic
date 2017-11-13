//
//  EClassMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension EClassMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<EClassMO>
	{
		return NSFetchRequest<EClassMO>(entityName: "EClass");
	}

	@NSManaged public var eclassId: Int
	@NSManaged public var name: String?
	@NSManaged public var fullName: String?
}
