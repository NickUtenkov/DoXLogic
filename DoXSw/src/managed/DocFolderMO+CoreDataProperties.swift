//
//  DocFolderMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension DocFolderMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<DocFolderMO>
	{
		return NSFetchRequest<DocFolderMO>(entityName: "DocumentFolders");
	}

	@NSManaged public var folderId: Int
	@NSManaged public var date: Date?
	@NSManaged public var nOrder: Int

}
