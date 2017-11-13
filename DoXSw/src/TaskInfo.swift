//
//  TaskInfo.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 09/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation

final class TaskInfo
{
	private var pTask:TaskUnprocessed? = nil

	private var _eclassId:Int = 0
	var eclassId:Int
	{
		get
		{
			if pTask != nil {return pTask!.eclassId}
			return _eclassId
		}
		set
		{
			_eclassId = newValue
		}
	}

	private var _displayEClassId:Int = 0
	var displayEClassId:Int
		{
		get
		{
			if pTask != nil {return pTask!.displayEClassId}
			return _displayEClassId
		}
		set
		{
			_displayEClassId = newValue
		}
	}
	
	private var _taskDescription:String? = nil
	var taskDescription:String?
		{
		get
		{
			if pTask != nil {return pTask!.taskDescription}
			return _taskDescription
		}
		set
		{
			_taskDescription = newValue
		}
	}
	
	private var _author:ContactMO? = nil
	var author:ContactMO?
		{
		get
		{
			if pTask != nil {return pTask!.author}
			return _author
		}
		set
		{
			_author = newValue
		}
	}
	
	private var _datePlanEnd:Date? = nil
	var datePlanEnd:Date?
		{
		get
		{
			if pTask != nil {return pTask!.datePlanEnd}
			return _datePlanEnd
		}
		set
		{
			_datePlanEnd = newValue
		}
	}
	
	private var _reworkReason:String? = nil
	var reworkReason:String?
		{
		get
		{
			if pTask != nil {return pTask!.reworkReason}
			return _reworkReason
		}
		set
		{
			_reworkReason = newValue
		}
	}
	
	private var _reworkDescription:String? = nil
	var reworkDescription:String?
		{
		get
		{
			if pTask != nil {return pTask!.reworkDescription}
			return _reworkDescription
		}
		set
		{
			_reworkDescription = newValue
		}
	}

	init(_ pTask0:TaskUnprocessed?)
	{
		pTask = pTask0
	}
}
