//
//  Downloader_Config.swift
//  DoXSw
//
//  Created by Nick Utenkov on 24/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class Downloader_Config : DataDownloader
{
	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Config".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource( "RequestConfig")
		m_dataXML = try? NSData(contentsOfFile:filePath,options:.alwaysMapped) as Data
		#else
			dlURL = Utils.createURL("AnswerConfig")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}

	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["getUserParameters"]
		{
			let succ = XMLFuncs.getSuccessAttributeValue(elem)
			if succ == 0
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Request Configuration failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical),object:errMessage)
				return
			}
			let items:[AEXMLElement] = elem.children.filter({ $0.name == "item" })
			for item in items
			{
				let itemName:String? = item.attributes["name"]
				let itemValue:String? = item.attributes["value"]
				if itemName != nil && itemValue != nil
				{
					//print(itemName!,itemValue!)
				}
			}
		}
	}
}
