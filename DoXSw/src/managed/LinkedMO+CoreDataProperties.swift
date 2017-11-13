//
//  LinkedMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

extension LinkedMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<LinkedMO>
	{
		return NSFetchRequest<LinkedMO>(entityName: "LinkedObject");
	}

	@NSManaged public var linkedId: Int
	@NSManaged public var isTmp: Bool
	@NSManaged public var linkedName: String?
	@NSManaged public var linkedSignatureHash: String?
	@NSManaged public var nKind: Int
	@NSManaged public var document: DocMO?
	@NSManaged public var file: DocContentMO?

}
