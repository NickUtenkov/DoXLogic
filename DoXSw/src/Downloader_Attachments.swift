//
//  Downloader_Attachments.swift
//  DoXSw
//
//  Created by Nick Utenkov on 31/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class Downloader_Attachments : Operation
{
	private var attsToDownload:[AttDownloadInfo]
	private var bFinishOK = true

	init(_ attsToDownload:[AttDownloadInfo])
	{
		self.attsToDownload = attsToDownload
		super.init()
	}
	
	override func main()
	{
		if isCancelled {return}
		if attsToDownload.count == 0 {return}
		#if !LocalXML
			let url = Utils.createURL()
			let filePath = Utils.getXMLFilePathFromResource("RequestFile")
			let requestFile_FormatStr = try? String(contentsOfFile:filePath, encoding:.ascii)
		#else
		#endif
		for pAtt in attsToDownload
		{
			var data:Data? = nil
			#if !LocalXML
				let requestStr = String(format:requestFile_FormatStr!,pAtt.attId,pAtt.offset)
				data = requestStr.data(using:.ascii)
			#else
				let pathUrl = String(format:"%@/%d",Bundle.main.resourcePath!,pAtt.attId)
				//print("path",pathUrl)
				let url = URL(fileURLWithPath:pathUrl)
			#endif
			let docDownloader = Downloader_Attachment(url,data,pAtt.attId)
			docDownloader.start()
			bFinishOK = docDownloader.isSuccess()
			if !bFinishOK {break}
		}
	}

	func finishOK() -> Bool
	{
		return bFinishOK
	}
}
