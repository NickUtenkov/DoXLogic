//
//  LogFile.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 11/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation

@objc final class LogFile : NSObject
{
	var bShowTime = true
	private var m_fileHandle:FileHandle? = nil
	private let m_startTime = Date()
	static let shared = LogFile()

	override init()
	{
		super.init()
		createLog("DoXLogic")
	}

	func createLog(_ fileName:String)
	{
		let defMan = FileManager.default
		let dtFormatter = DateFormatter()
		dtFormatter.dateFormat = "MM_dd_HH_mm_ss"
		let logDir = String(format:"%@/Logs",Utils.GetDBDir())
		try? defMan.createDirectory(atPath:logDir,withIntermediateDirectories:true,attributes:nil)
		let filePath = String(format:"%@/%@_%@.c++",logDir,fileName,dtFormatter.string(from:m_startTime))
		print(filePath)
		try? "".write(toFile:filePath,atomically:false,encoding:.utf8)//creating file
		m_fileHandle = FileHandle(forWritingAtPath:filePath)
	}

	func write(_ str:String,_ endL:Bool = true)
	{
		objc_sync_enter(self)
		#if DEBUG
		print(str)
		#endif
		if let fh = m_fileHandle
		{
			fh.seekToEndOfFile()
			if bShowTime
			{
				let strTime = String(format:"%9.3f ",Date().timeIntervalSince(m_startTime))
				fh.write(strTime.data(using: .utf8)!)
			}
			fh.write(str.data(using: .utf8)!)
			if endL {fh.write("\n".data(using: .utf8)!)}
		}
		objc_sync_exit(self)
	}

	func writeV(_ strFormat:String,_ args:CVarArg...)
	{
		let str = String(format:strFormat,arguments:args)
		write(str)
	}

	func write(_ exception:NSException)
	{
		objc_sync_enter(m_fileHandle as Any)
		let oldShowTime = bShowTime
		bShowTime = false
		write(" ")
		write(String(format:"*** Exception '%@' a little bit occured",exception.name.rawValue))
		if let strReason = exception.reason {write(String(format:"*** Reason '%@'",strReason))}
		if let strAdrs = exception.userInfo?[UEH.AddressesKey] as? [String]
		{
			strAdrs.forEach{write($0)}
		}
		write(" ")
		bShowTime = oldShowTime
		objc_sync_exit(m_fileHandle as Any)
	}
}
