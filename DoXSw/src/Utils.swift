//
//  Utils.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 Nick Utenkov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class Utils
{
	static let timeOutSeconds:TimeInterval = 300
	#if TARGET_IPHONE_SIMULATOR
	static let ControlDateLabelFontSize:CGFloat = 11
	#else
	static let ControlDateLabelFontSize:CGFloat = 14
	#endif
	static let strRecips = ["получатель","получателей","получателя"]
	static let strSenders = ["отправитель","отправителей","отправителя"]

	static func createServerApplicationURLString() -> String
	{
		let server = prefsGetString(GlobDat.kKey_ServerName)
		let port = prefsGetInteger(GlobDat.kKey_ServerPort)
		let appName = prefsGetString(GlobDat.kKey_ApplicationName)
		let bIsSSL = prefsGetBool(GlobDat.kKey_SSLEnable)
		return String(format:"http%@://%@:%d/%@/",(bIsSSL ? "s" : ""),server!,port,appName!)
	}

	static func createURL(_ fileName:String = "") -> URL
	{
		var url:URL?
		#if !LocalXML
		let str = String(format:"%@%@",createServerApplicationURLString(),"iservices")
		url = URL(string:str)
		if url == nil
		{
			let msg = String(format:"WrongURL".localized,str)
			let alrt = UIAlertController(title:"Error".localized,message:msg,preferredStyle: .alert)
			let okButton = UIAlertAction(title: "Yes", style: .default, handler: nil)
			alrt.addAction(okButton)
			UIApplication.shared.windows[0].rootViewController?.present(alrt, animated: true)
		}
		#else
		let xmlPath = Utils.getXMLFilePathFromResource(fileName)
		url = URL(fileURLWithPath:xmlPath)
		#endif
//print("createURL",url!)
		return url!
	}

	static func getXMLFilePathFromResource(_ fileName:String) -> String
	{
		return Bundle.main.path(forResource: fileName, ofType: "xml")!
	}
	
	static func prefsSet(_ val:Any,_ key:String)
	{
		let defaults = UserDefaults.standard
		defaults.set(val,forKey: key)
		defaults.synchronize()
	}

	static func prefsGetString(_ key:String) -> String?
	{
		return UserDefaults.standard.string(forKey:key)
	}

	static func prefsGetInteger(_ key:String) -> Int
	{
		return UserDefaults.standard.integer(forKey:key)
	}
	
	static func prefsGetBool(_ key:String) -> Bool
	{
		return UserDefaults.standard.bool(forKey:key)
	}

	static func prefsGetFloat(_ key:String) -> Float
	{
		return UserDefaults.standard.float(forKey:key)
	}

	static func getDateFromString(_ strDate:String?) -> Date?
	{
		var dtFormatter:DateFormatter!// = MyDF.df8
		if (strDate == nil) || (strDate!.length == 0) {return nil}
	
		switch strDate!.length
		{
			case 17 :
				dtFormatter = MyDF.df17
				break
			case 14 :
				dtFormatter = MyDF.df14
				break
			default :
				dtFormatter = MyDF.df8
				break
		}
		return dtFormatter.date(from: strDate!) as Date?
	}

	static func getSettingsDBUserName() -> String
	{
		#if !LocalXML
		var usrName = ""
		if let usrName0 = prefsGetString(GlobDat.kKey_UserName) {usrName = usrName0}
		#else
		let usrName = "LocalXML"
		#endif
		return usrName
	}

	static func createUniqUserKey() -> String
	{
		let usrName = getSettingsDBUserName()
		#if !LocalXML
		let serverName = prefsGetString(GlobDat.kKey_ServerName)
		let appName = prefsGetString(GlobDat.kKey_ApplicationName)
		let resourceName = getSettingsDBResourceName()
		return String(format:"%@_%@_%@_%@",usrName,serverName!,appName!,resourceName)
		#else
		return usrName
		#endif
	}
	
	static func createUniqDeviceUserContactKey() -> String
	{
		return "\(createUniqUserKey())_DeviceUserContact"
	}
	
	static func createUniqDeviceUserIsBossKey() -> String
	{
		return "\(createUniqUserKey())_DeviceUserIsBoss"
	}
	
	static func createUniq_showProgressKey() -> String
	{
		return "\(createUniqUserKey())_showProgress"
	}

	static func createUniq_pressedEClassIdKey() -> String
	{
		return "\(createUniqUserKey())_pressedEClassId"
	}

	static func createUniq_pressedFolderIdKey() -> String
	{
		return "\(createUniqUserKey())_pressedFolderId"
	}

	static func createUniq_FoldersLockedKey() -> String
	{
		return "\(createUniqUserKey())_FoldersLocked"
	}
	
	static func createUniq_DatesLockedKey() -> String
	{
		return "\(createUniqUserKey())_DatesLocked"
	}

	static func createUniq_MainButtonIdxKey() -> String
	{
		return "\(createUniqUserKey())_MainButtonIdx"
	}

	static func createUniq_pressedAcquFolderIdKey() -> String
	{
		return "\(createUniqUserKey())_pressedAcquFolderId"
	}
	
	static func createUniq_AcquLockedKey() -> String
	{
		return "\(createUniqUserKey())_AcquLocked"
	}

	static func getDBName() -> String
	{
		return String(format:"%@.sqlite",createUniqUserKey())
	}

	static func createFilesDir()
	{
		try? FileManager.default.createDirectory(atPath:createWorkDirPathString(),withIntermediateDirectories:true,attributes:nil)
	}

	static func GetDBDir() -> String
	{
		return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		//return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
	}

	static func createWorkDirPathString() -> String
	{
		return "\(GetDBDir())/\(createUniqUserKey())"
	}

	static func createFilePathString(_ fileId:Int) -> String
	{
		return "\(createWorkDirPathString())/\(fileId)"
	}
	
	static func getFileSize(_ fullPath:String) -> UInt64
	{
		var fileSize:UInt64 = 0
		if let fileInfoDict = try? FileManager.default.attributesOfItem(atPath:fullPath)
		{
			fileSize = fileInfoDict[FileAttributeKey.size] as! UInt64
		}
		return fileSize
	}

	static func getFileSize(_ fileId:Int) -> UInt64
	{
		return getFileSize(createFilePathString(fileId))
	}

	static func addDocFolderToMap(_ mapDF:inout Dictionary<Int,Set<Int>>,_ docId:Int,_ folderId:Int)
	{
		var st:Set<Int>
		let idx = mapDF.index(forKey:docId)
		if idx == nil
		{
			st = Set()
			//mapDF[docId] = st//mapDF.updateValue(docId,forKey:st)
		}
		else {st = mapDF[docId]!}
		st.insert(folderId)
	}

	static var types:Array<(mime:String,type:String)> =
	[
		("application/vnd.openxmlformats-officedocument.wordprocessingml.document" , ".docx"),
		("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" , ".xlsx"),
		("application/msword" , ".doc"),
		("application/msexcel" , ".xls"),
		("application/vnd.ms-excel" , ".xls"),
		("application/pdf" , ".pdf"),
		("text/plain" , ".txt"),
		("text/rtf" , ".rtf"),
		("application/vnd.oasis.opendocument.text" , ".odt"),
		("image/jpeg" , ".jpg"),
		("image/tiff" , ".tif"),
		("image/gif" , ".gif"),
		("image/png" , ".png"),
		("image/x-png" , ".png"),
		("image/bmp" , ".bmp"),
		("text/plain" , ".zip")
	]
	static let imgTypes = [".jpg", ".tif", ".gif", ".png", ".bmp"]

	static func GetExtensionForMIMEType(_ mimeType:String?) -> String
	{
		if mimeType != nil
		{
			for (mime,type) in types
			{
				if mimeType!.lowercased().range(of:mime) != nil {return type}
			}
		}
		return ""
	}

	static func GetMIMEType(_ fileName:String?) -> String
	{
		if fileName != nil
		{
			for (mime,type) in types
			{
				if fileName!.lowercased().range(of:type) != nil {return mime}
			}
		}
		return ""
	}
	
	static func isImageMime(_ mimeType:String) -> Bool
	{
		let strExt = GetExtensionForMIMEType(mimeType)
		if imgTypes.index(where:{$0.lowercased().range(of:strExt) != nil}) != nil {return true}
		return false
	}

	static func parseFiles(_ fileItems:[AEXMLElement],_ listAttachments:inout [AttDownloadInfo],_ pMO:NSManagedObject,_ moSet:Set<DocContentMO>?,_ selAdd:Selector?,_ selRemove:Selector?,_ nAttMaxSize:UInt64,_ outInformNotDownloaded:NSMutableArray)
	{
		outInformNotDownloaded.removeAllObjects()
		var attsToDelete:Set<Int> = []
		if moSet != nil
		{
			for pDocAtt in moSet! {attsToDelete.insert(pDocAtt.fileId)}
		}
		let pMocDoc = pMO.managedObjectContext!
		for fileItem in fileItems
		{
			let attrs = fileItem.attributes
			let attId = Int(attrs["id"]!)!
			if Synchronizer.isAttAlreadyAddedToDownload(attId)
			{
				if moSet != nil {attsToDelete.remove(attId)}
				continue
			}
			let fileName = attrs["name"]
			var mimeType = ""
			if let mimeTmp = attrs["mime"]
			{
				mimeType = mimeTmp
			}
			let extStr = GetExtensionForMIMEType(mimeType)//check for supported mime type
			if extStr.length == 0 {mimeType = GetMIMEType(fileName)}
			if mimeType.length > 0
			{
				//if (isStringsEqual(mimeType,@"image/x-png")) mimeType = @"image/png"
				let attSize = UInt64(attrs["size"]!)!
				var nOrder = 0
				if let strOrder = attrs["nord"] {nOrder = Int(strOrder)!}
				var previousFileHashInDB:String? = ""
				let fSize = getFileSize(attId)
				var bAddToAttachmentList = true
				var pDocAtt:DocContentMO? = nil
				if attSize <= nAttMaxSize
				{
					if moSet != nil {attsToDelete.remove(attId)}
					var bShouldAdd = false
					if moSet != nil
					{
						let idx = moSet!.index(where:{$0.fileId == attId})
						if idx != nil {pDocAtt = moSet![idx!]}
					}
					if pDocAtt == nil
					{
						bShouldAdd = true
						if let pDocAtt1:DocContentMO = CorDatFuncs.fetchOneRecord(NSPredicate(format:"fileId==%d",attId),DocContentMO.fetchRequest(),pMocDoc)
						{
							pDocAtt = pDocAtt1
						}
					}
					if pDocAtt == nil
					{
						pDocAtt = NSEntityDescription.insertNewObject(forEntityName: "DocContent", into: pMocDoc) as? DocContentMO
						pDocAtt!.fileId = attId
					}
					else {previousFileHashInDB = pDocAtt!.fileHash}
					if bShouldAdd && (selAdd != nil) {pMO.perform(selAdd!,on:Thread.current ,with:pDocAtt,waitUntilDone:true)}
					#if LocalXML
					if previousFileHashInDB == nil {previousFileHashInDB = ""}
					#endif
					
					pDocAtt!.fileSize = attSize
					pDocAtt!.nOrder = nOrder//can changed,so update
					pDocAtt!.mime = mimeType
					pDocAtt!.fileName = fileName
					if let strHash = attrs["signatureHash"]
					{
						pDocAtt!.fileHash = strHash
					}
					else {pDocAtt!.fileHash = ""}//for not adding hashes in LocalXML data
					
					//if file hash changed then file was changed on server
					let bDownloadFromZeroOffset = previousFileHashInDB != pDocAtt!.fileHash//if false - append to existing file
					let bShouldDownLoad = (bDownloadFromZeroOffset || (fSize < attSize))
					if bShouldDownLoad
					{//file size may be changed due to attachment modified on server
						//partially downloaded file -> should append file
						//file changed on server -> should erase old file & create new file
						if bDownloadFromZeroOffset {Utils.deleteAttachmentFile2(attId,false)}
						let adi = AttDownloadInfo(attId,attSize,(bDownloadFromZeroOffset ? 0 : fSize))
						Synchronizer.addAttToDownload(adi.attId)
						listAttachments.append(adi)
					}
				}
				else
				{
					//if file already downloaded (fSize == attSize) we will add it to list of attachments
					if fSize != attSize//fSize can be not zero if file was downloaded in previous synchronizations
					{
						outInformNotDownloaded.add(fileName as Any)
						outInformNotDownloaded.add(attSize)
						bAddToAttachmentList = false
					}
				}
				if bAddToAttachmentList
				{
					if pDocAtt != nil {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteAtt),object:attId)}
				}
			}
		}
		if moSet != nil
		{
			for attId in attsToDelete
			{
				if let idx = moSet!.index(where:{$0.fileId == attId})
				{
					pMO.perform(selAdd!,on:Thread.current ,with:moSet![idx],waitUntilDone:true)
				}
			}
		}
	}

	static func deleteAttachmentFile2(_ attId:Int,_ bErasePDFDraw:Bool)
	{
		//print("delete attId",attId)
		try? FileManager.default.removeItem(atPath:createFilePathString(attId))
	}

	static func informAttNotLoaded(_ pDocRec:DocMO,_ fName:String,_ attSize:UInt64)
	{
		let strFormat = "strAttNotLoaded".localized
		let str1 = pDocRec.docInfoForAttachments
		let str2 = String(format:"strAttAndSize".localized,fName,(Float(attSize))/1048576)
		let strMsg = String(format:strFormat,str1,str2)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchErrorLoggableDownload),object:strMsg)
	}
	
	static func informNotDownloaded(_ arInform:NSArray,_ pDocRec:DocMO)
	{
		let cObj = arInform.count / 2
		if cObj > 0
		{
			for i in 0..<cObj
			{
				let fName:String = arInform.object(at:(i*2+0)) as! String
				let fSize:UInt64 = arInform.object(at:(i*2+1)) as! UInt64
				informAttNotLoaded(pDocRec,fName,fSize)
			}
		}
	}

	static func timeToString(_ remainTime:Int) -> String
	{
		var strTime = ""
		let leftSeconds = remainTime % 60
		var leftMinutes = (remainTime-leftSeconds)/60

		if leftMinutes == 0
		{
			strTime = String(format:"TimeLeft1".localized,leftSeconds)
		}
		else if (leftMinutes < 60) && (leftMinutes >= 5)
		{
			strTime = String(format:"TimeLeft4".localized,leftMinutes)
		}
		else if leftMinutes<5
		{
			strTime = String(format:"TimeLeft2".localized,leftMinutes,leftSeconds)
		}
		else
		{
			let leftHours = leftMinutes/60
			leftMinutes = leftMinutes % 60
			strTime = String(format:"TimeLeft3".localized,leftHours,leftMinutes)
		}

		return strTime
	}

	static func runOnUI(_ block:@escaping () -> Swift.Void)
	{
		if Thread.current.isMainThread {block()}
		else {DispatchQueue.main.async(execute: block)}
	}

	static func strNilOrEmpty(_ str:String?) -> Bool
	{
		if str == nil {return true}
		if str! == "" {return true}
		return false
	}

	static func createControlDateLabel(_ originY:CGFloat,_ width:CGFloat) -> UILabel
	{
		let labelDate = UILabel(frame:CGRect(x:0,y:originY,width:width,height:ControlDateLabelFontSize+4))
		labelDate.autoresizingMask = .flexibleWidth
		labelDate.backgroundColor = UIColor.clear
		labelDate.textColor = UIColor(red:0.98,green:0.36,blue:0.36,alpha:1.0)//fc5d5d
		labelDate.textAlignment = .center
		#if TARGET_IPHONE_SIMULATOR
		let fnt = UIFont(name:"AmericanTypewriter-Bold",size:ControlDateLabelFontSize)
		#else
		let fnt = UIFont(name:"AmericanTypewriter-CondensedBold",size:ControlDateLabelFontSize)
		#endif
		labelDate.font = fnt
		
		return labelDate
	}

	static func createRecipientsString(_ numb:Int) -> String
	{
		var idx = 1,ost = numb % 10
		if numb > 10 && numb < 20 {idx = 1}
		else if ost == 1 {idx = 0}
		else if (ost == 2) || (ost == 3) || (ost == 4) {idx = 2}
		return String(format:"и еще %d %@…",numb,strRecips[idx])
	}
	
	static func createSendersString(_ numb:Int) -> String
	{
		var idx = 1,ost = numb % 10
		if numb > 10 && numb < 20 {idx = 1}
		else if ost == 1 {idx = 0}
		else if (ost == 2) || (ost == 3) || (ost == 4) {idx = 2}
		return String(format:"и еще %d %@…",numb,strSenders[idx])
	}
	
	static func placeViewsEvenly(_ superView:UIView,_ views:[UIView])
	{
		var sumWidth:CGFloat = 0
		let count = views.count
		for i in 0..<count {sumWidth += views[i].frame.size.width}
		let gap = (superView.frame.size.width-sumWidth)/CGFloat(count+1)
		var prevViewoffsetX:CGFloat = 0
		for i in 0..<count
		{
			views[i].setXOrigin(prevViewoffsetX+gap)
			views[i].alpha = 0.0
			views[i].isHidden = false
			prevViewoffsetX = views[i].frame.origin.x+views[i].frame.size.width
		}
		UIView.animate(withDuration:0.5,animations:
		{
				views.forEach{$0.alpha = 1.0}
		})
	}

	static func installUncaughtExceptionHandler()
	{
		NSSetUncaughtExceptionHandler{e in UEH.handleException(e)}
		signal(SIGABRT) { signal in UEH.signalException(signal) }
		signal(SIGILL) { signal in UEH.signalException(signal) }
		signal(SIGSEGV) { signal in UEH.signalException(signal) }
		signal(SIGFPE) { signal in UEH.signalException(signal) }
		signal(SIGBUS) { signal in UEH.signalException(signal) }
		signal(SIGPIPE) { signal in UEH.signalException(signal) }
	}
	static func restoreExceptionHandler()
	{
		NSSetUncaughtExceptionHandler(nil)
		signal(SIGABRT,nil)
		signal(SIGILL,nil)
		signal(SIGSEGV,nil)
		signal(SIGFPE,nil)
		signal(SIGBUS,nil)
		signal(SIGPIPE,nil)
	}

	static func getEClassesString() -> String
	{
		//EClasses.loadFromStore()
		if EClasses.count() > 0
		{
			var strOut = ""
			let ids:[Int] =
			[
				GlobDat.eClass_DocflowReferencesAgreeDocument,
				GlobDat.eClass_DocflowReferencesApproveDocument,
				GlobDat.eClass_DocflowReferencesReviewDocument,
				GlobDat.eClass_WorkflowReferencesFormalTask,
				GlobDat.eClass_DocflowTaskReadDocument
			]
			for idVal in ids
			{
				strOut.append(String(format:"\n\t\t\t\t<item id=\"%d\"/>",idVal))
			}
			return strOut
		}
		return ""
	}

	static func getSettingsDBResourceName() -> String
	{
		var resourceName = prefsGetString(GlobDat.kKey_ResourceName)
		if resourceName == nil {resourceName = "Invalid resource name"}
		return resourceName!
	}

	static func getSettingsDBRoleId() -> Int
	{
		return prefsGetInteger(GlobDat.kKey_RoleId)
	}
}
