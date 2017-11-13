//
//  TaskProcessed+CoreDataClass.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

@objc(TaskProcessed)
public class TaskProcessed: NSManagedObject
{
	//public typealias TP = TaskProcessed
	static let executeTypeAssignExecutor = 1
	static let executeTypeAgree = 2
	static let executeTypeApprove = 4
	static let executeTypeResultOfTask = 8
	static let executeTypeResolution = 16
	static let executeTypeConsidered = 32
	static let executeTypeAcceptExecution = 64
	static let executeTypeChildTaskIssued = 128
	static let executeTypeConfirmRead = 256
}
