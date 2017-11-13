//
//  Downloader_DoLogin.swift
//  DoXSw
//
//  Created by nick on 21/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class Downloader_DoLogin : DataDownloader
{
	private var m_strPassword:String = ""
	init(password:String)
	{
		super.init()
		m_strPassword = password
	}

	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_Login".localized
		#if !LocalXML
		dlURL = Utils.createURL()
		let filePath = Utils.getXMLFilePathFromResource("RequestSessionId")
		let loginFormatStr = try? String(contentsOfFile:filePath, encoding:.ascii)
		let appVer = "3.6.00"
		let loginFormated = String(format:loginFormatStr!,Utils.getSettingsDBResourceName(),Utils.getSettingsDBUserName(),m_strPassword,Utils.getSettingsDBRoleId(),appVer)
		m_dataXML = loginFormated.data(using: .utf8)
		#else
		dlURL = Utils.createURL("AnswerSessionId")
		#endif
		super.main()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRequestInGroupCompleted),object:nil)
	}

	override func parse(_ doc:AEXMLDocument?)
	{
		if let elem = doc?.root["body"]["doLogin"]
		{
			let succ = XMLFuncs.getSuccessAttributeValue(elem)
			if succ == 1
			{
				var attrs = elem.attributes
				if let contactId = Int(attrs["contactId"]!)
				{
					GlobDat.deviceUserContactId = contactId
					Utils.prefsSet(contactId,Utils.createUniqDeviceUserContactKey())
					if let strIsBoss = elem.children.first?.attributes["isBigBoss"]
					{
						let bIsBoss = strIsBoss.bool
						GlobDat.bIsBoss = bIsBoss
						Utils.prefsSet(bIsBoss,Utils.createUniqDeviceUserIsBossKey())
					}
				}
			}
			else
			{
				var errMessage = XMLFuncs.getErrorFromErrorNode(elem)
				if errMessage == nil {errMessage = "Login failed"}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorCritical),object:errMessage)
			}
		}
	}
}
