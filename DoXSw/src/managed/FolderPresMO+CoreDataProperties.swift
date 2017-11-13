//
//  FolderPresMO+CoreDataProperties.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData


extension FolderPresMO
{
	@nonobjc public class func fetchRequest() -> NSFetchRequest<FolderPresMO>
	{
		return NSFetchRequest<FolderPresMO>(entityName: "PresentationFolder");
	}

	@NSManaged public var folderId: Int
	@NSManaged public var folderName: String?
	@NSManaged public var nOrder: Int

}
