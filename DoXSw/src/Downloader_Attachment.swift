//
//  Downloader_Attachment.swift
//  DoXSw
//
//  Created by Nick Utenkov on 31/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class Downloader_Attachment : DataDownloader
{
	private var m_FileId:Int

	init(_ url:URL,_ data:Data?,_ fileId:Int)
	{
		m_FileId = fileId
		super.init()
		dlURL = url
		m_dataXML = data
		m_bDownLoadingAttachment = true
	}

	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Attach".localized
		m_notifStrDidReceiveData = String(format:"%@%d", String(describing: Downloader_Attachment.self),m_FileId)
		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.addToFile), name:NSNotification.Name(rawValue:m_notifStrDidReceiveData), object:nil)

		super.main()

		nc.removeObserver(self, name:NSNotification.Name(rawValue:m_notifStrDidReceiveData),object:nil)
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		appendToFile(getRequesterResponseData())
	}

	@objc func addToFile(notification: NSNotification)
	{
		let data = getRequesterResponseData()
		if data.length > 10000
		{
			appendToFile(data)
			resetRequesterResponseData()
		}
	}

	func appendToFile(_ data:NSMutableData)
	{
		let filePath = Utils.createFilePathString(m_FileId)
		//print("appendToFile",filePath,"",data.count)
		//print(Utils.GetDBDir())
		var fileHandle = FileHandle(forWritingAtPath:filePath)
		if fileHandle == nil
		{//[String : Any]
			FileManager.default.createFile(atPath:filePath,contents:nil,attributes:nil)
			fileHandle = FileHandle(forWritingAtPath:filePath)
		}
		if fileHandle != nil
		{
			fileHandle!.seekToEndOfFile()
			fileHandle!.write(data as Data)
		}
	}
}
