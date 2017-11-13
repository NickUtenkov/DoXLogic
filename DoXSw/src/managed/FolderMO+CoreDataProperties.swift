//
//  FolderMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension FolderMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<FolderMO>
	{
		return NSFetchRequest<FolderMO>(entityName: "FoldersHierarchy");
	}

	@NSManaged public var folderId: Int
	@NSManaged public var nOrder: Int
	@NSManaged public var operationUID: String?
	@NSManaged public var folderName: String?
	@NSManaged public var folderParentId: Int

}
