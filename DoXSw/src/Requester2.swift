//
//  Requester.swift
//  DoXSw
//
//  Created by nick on 20/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class Requester2 : NSObject
{
	var m_responseData:NSMutableData = NSMutableData()
	var m_contentType:String = ""
	
	var m_strNotification_DidReceiveData:String = ""
	fileprivate var m_errStr:String? = nil
	static var sessionId:String = ""
	var theRequest:URLRequest!
	var semaphore:DispatchSemaphore? = nil

	init(_ inURL:URL,_ method:String,_ inData:Data?,_ contentType:String,_ timeOut:TimeInterval)
	{
		super.init()
		theRequest = URLRequest(url:inURL,cachePolicy:.reloadIgnoringLocalCacheData,timeoutInterval:timeOut)
		#if LocalXML
		#else
			theRequest.httpMethod = method
			theRequest.setValue("Keep-Alive",forHTTPHeaderField:"Connection")//KeepAliveTimeout 15
			theRequest.setValue(contentType,forHTTPHeaderField:"Content-Type")
			if inData != nil {theRequest.setValue(String(format:"%lu",inData!.count),forHTTPHeaderField:"Content-Length")}
			
			theRequest.setValue("gzip",forHTTPHeaderField:"Accept-Encoding")
			
			if !Requester2.sessionId.isEmpty
			{
				theRequest.setValue(String(format:"JSESSIONID=%@",Requester2.sessionId),forHTTPHeaderField:"Cookie")
			}
			else
			{
				let dict = Bundle.main.infoDictionary
				let strVersion:String? = dict?["CFBundleVersion"] as! String?
				let strVersionShort:String? = dict?["CFBundleShortVersionString"] as! String?
				let dev = UIDevice.current
				let agentStr = String(format:"%@;%@ %@;Bundle(%@),BundleShort(%@);",dev.name,dev.systemName,dev.systemVersion,strVersion!,strVersionShort!)
				theRequest.setValue(agentStr,forHTTPHeaderField:"User-Agent")
			}
			if inData != nil {theRequest.httpBody = inData!}
		#endif
	}

	func execute() -> String?
	{
		m_errStr = nil
		semaphore = DispatchSemaphore(value: 0)

		if m_strNotification_DidReceiveData.isEmpty
		{
			let session = URLSession.shared
			session.dataTask(with: theRequest)
			{[unowned self] data, response, error in
				if error != nil
				{
					self.m_errStr = error!.localizedDescription
				}
				else
				{
					#if !LocalXML
					if response != nil {self.extractSessionId(response!)}
					#endif
					if data != nil
					{
						self.m_responseData.append(data!)
					}
				}
				self.semaphore!.signal()
			}.resume()
		}
		else
		{
			let session = URLSession(configuration: .`default`,delegate:self,delegateQueue: nil)
			session.dataTask(with: theRequest).resume()
		}

		_ = semaphore!.wait(timeout: .distantFuture)

		return m_errStr
	}

	func getData() -> NSMutableData
	{
		return m_responseData
	}
	
	func resetResponseData()
	{
		m_responseData = NSMutableData()
	}

	func extractSessionId(_ response:URLResponse)
	{
		#if !LocalXML
			if let dict:[AnyHashable : Any] = (response as? HTTPURLResponse)?.allHeaderFields
			{
				if let str = dict["ContentType"] as? String {m_contentType = str}
				if let str = dict["Set-Cookie"] as? String
				{
					if let rng1:Range<String.Index> = str.range(of:"JSESSIONID=")
					{
						let str2 = str.substring(from:rng1.upperBound)
						if let rng2:Range<String.Index> = str2.range(of:";")
						{
							let rng3 = str2.startIndex..<rng2.lowerBound
							Requester2.sessionId = str2.substring(with:rng3)
						}
					}
				}
			}
		#endif
	}
}

extension Requester2 : URLSessionTaskDelegate,URLSessionDataDelegate
{
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
	{
		if error != nil
		{
			m_errStr = error!.localizedDescription
		}
		semaphore!.signal()
	}
	
	private func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse)
	{
		#if !LocalXML
			extractSessionId(response)
		#endif
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
	{
		self.m_responseData.append(data)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue: m_strNotification_DidReceiveData),object:data.count)
	}
}
