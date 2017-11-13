//
//  DataDownloader.swift
//  DoXSw
//
//  Created by nick on 20/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

class DataDownloader : Operation
{
	var dlURL:URL?
	var m_dataXML:Data?
	var m_timeout:TimeInterval = Utils.timeOutSeconds//can be changed in subclasses
	var m_notifStrDidReceiveData:String = ""
	
	var m_bDownLoadingAttachment:Bool = false,bIsXmlContentType:Bool = false
	private var bFinishedOK:Bool = false
	private var m_pRequester:Requester2?
	var m_requestName:String = ""

	override func main()
	{
		if isCancelled {return}
		m_pRequester = Requester2(dlURL!,"POST",m_dataXML,"text/xml",m_timeout)
		m_pRequester!.m_strNotification_DidReceiveData = m_notifStrDidReceiveData
		#if LocalXML
		m_pRequester!.m_contentType = (!m_bDownLoadingAttachment ? "text/xml" : "")
		#endif
		let strErr:String? = m_pRequester!.execute()
		if strErr != nil
		{
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kSynchErrorCritical),object:strErr)
			print("Requester err",strErr!,dlURL?.absoluteString ?? "")
		}
		else
		{
			bIsXmlContentType = (m_pRequester!.m_contentType == "text/xml")
			bFinishedOK = true
			callParser(m_pRequester!.getData())
		}
	}

	func parse(_ doc:AEXMLDocument?)
	{
		//print("parse from base class")
	}

	func callParser(_ responseData:NSMutableData)
	{
		if !isCancelled
		{
			if responseData.length > 0
			{
				if (!m_bDownLoadingAttachment || bIsXmlContentType)
				{
					do
					{//https://github.com/tadija/AEXML
						let doc:AEXMLDocument = try AEXMLDocument.init(xml:responseData as Data)
						if !isSevereSynchError(doc) {parse(doc)}
					}
					catch
					{
						let notifStr = String(format:"ServerBadData".localized,m_requestName,(error as NSError).localizedDescription)
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kSynchErrorCritical),object:notifStr)
					}
				}
				else
				{
					//download tail of attachment(main part of att is downloaded during Requester's didReceiveData:)
					//can not get here if all att data already written to file
					parse(nil)
				}
			}
			else
			{
				if !m_bDownLoadingAttachment
				{
					let notifStr = String(format:"ServerNoData".localized,m_requestName);
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kSynchErrorCritical),object:notifStr)
				}
			}
		}
	}

	func isSevereSynchError(_ doc:AEXMLDocument) -> Bool
	{
		var rc = false
		let attrs = doc.root["body"]["error"].attributes
		if let attrCode = attrs["code"]
		{
			if attrCode.uppercased().range(of:"ERROR") != nil
			{
				rc = true
				if let errMsg = attrs["message"]
				{
					if errMsg.range(of:"Not authorized") != nil
					{
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kAuthorizationFailed),object:errMsg)
					}
					else
					{
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kSynchErrorCritical),object:errMsg)
					}
				}
				else
				{
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: GlobDat.kSynchErrorCritical),object:"failed")
				}
			}
		}
		return rc;
	}

	func isSuccess() -> Bool
	{
		return bFinishedOK;
	}

	func getRequesterResponseData() -> NSMutableData
	{
		return m_pRequester!.m_responseData
	}

	func resetRequesterResponseData()
	{
		m_pRequester!.resetResponseData()
	}
}
