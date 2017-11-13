//
//  Downloader_FolderDoc.swift
//  DoXSw
//
//  Created by Nick Utenkov on 03/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_FolderDoc : DataDownloader
{
	private var m_docId = 0,m_docVersion = 0
	private var m_pDocMO:DocMO
	private var m_pMocDoc:NSManagedObjectContext
	private var m_requestContact:NSFetchRequest<ContactMO>
	private var m_requestDocument:NSFetchRequest<DocMO>
	private var m_attsToDownload:[AttDownloadInfo] = []
	private var outInformNotDownloaded:NSMutableArray = NSMutableArray()
	private var nAttMaxSize:UInt64 = 0

	init(_ url:URL,_ data:Data?,_ pDocMO:DocMO)
	{
		m_pDocMO = pDocMO
		m_pMocDoc = pDocMO.managedObjectContext!
		m_requestContact = ContactMO.fetchRequest()
		m_requestDocument = DocMO.fetchRequest()
		super.init()
		dlURL = url
		m_dataXML = data
	}

	override func main()
	{
		if isCancelled {return}
		m_requestName = "RequestName_DocList".localized
		super.main()
	}
	
	override func parse(_ doc:AEXMLDocument?)
	{
		var fAttMaxSize = Utils.prefsGetFloat(GlobDat.kKey_MaxAttMb)
		if fAttMaxSize == 0.0 {fAttMaxSize = 2.0}
		nAttMaxSize = (UInt64)(fAttMaxSize*1024.0*1024.0)
		
		if let elem = doc?.root["body"]["getDocumentsListAcquaintance"]["item"]
		{
			//print("Downloader_FolderDoc",m_pDocMO.docId)
			parseDocument(elem)
			let docChilds = elem.children
			
			let selRemoveAH = #selector(m_pDocMO.removeFromAgreeHistory as (_ value: AgreeHistoryMO) -> Void)
			CorDatFuncs.removeRelationshipObjects(m_pDocMO,m_pDocMO.agreeHistory!,selRemoveAH,true)
			if let items = docChilds.filter({ $0.name == "agreeHistoryList" }).first?.children.filter({ $0.name == "item" })
			{
				let selAdd = #selector(m_pDocMO.addToAgreeHistory as (_ value: AgreeHistoryMO) -> Void)
				CorDatFuncs.parseAgreeHistory(m_pDocMO,m_pDocMO.agreeHistory!,selAdd,items,m_requestContact)
			}
			
			let selRemoveEL = #selector(m_pDocMO.removeFromExecutionList as (_ value: ExecutionListMO) -> Void)
			CorDatFuncs.removeRelationshipObjects(m_pDocMO,m_pDocMO.executionList!,selRemoveEL,true)
			if let items = docChilds.filter({ $0.name == "formalList" }).first?.children.filter({ $0.name == "item" })
			{
				m_pDocMO.parseExecutionList(items,m_requestContact)
			}
			
			if let docFiles = docChilds.filter({ $0.name == "files" }).first?.children.filter({ $0.name == "item" })
			{
				let selAdd = #selector(m_pDocMO.addToAttSet as (_ value: DocContentMO) -> Void)
				let selRemove = #selector(m_pDocMO.removeFromAttSet as (_ value: DocContentMO) -> Void) 
				Utils.parseFiles(docFiles,&m_attsToDownload,m_pDocMO,m_pDocMO.attSet,selAdd,selRemove,nAttMaxSize,outInformNotDownloaded)
				Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
			}
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocumentAccepted),object:nil)
			CoreDataManager.sharedInstance.saveContext(m_pMocDoc)

			var bAttsDownloaded = true
			if m_attsToDownload.count > 0
			{
				let pAttachmentsDownloader = Downloader_Attachments(m_attsToDownload)
				pAttachmentsDownloader.start()
				bAttsDownloaded = pAttachmentsDownloader.finishOK()
			}
			if bAttsDownloaded
			{
				//t0 = mach_absolute_time()
				setDocVisibilityAndUpdateVersion()
				//parseTime += m_nanoTime.GetSecondsSince(t0)
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchronizationPortion),object:nil)
			}
		}
	}
	
	func parseDocument(_ elem:AEXMLElement)
	{
		let attrs = elem.attributes
		m_docId = Int(attrs["id"]!)!
		//print("m_docId",m_docId)

		m_docVersion = XMLFuncs.getVersionFromAttrs(attrs)
		if let strPrior = attrs["priority"] {m_pDocMO.priority = strPrior.bool}
		m_pDocMO.docTitle = attrs["name"]
		m_pDocMO.docket = attrs["docket"]
		m_pDocMO.inRegistration = attrs["inRegistration"]
		m_pDocMO.type = attrs["documentType"]
		m_pDocMO.eclass = attrs["eclass"]
		m_pDocMO.fullNameOfBClass = attrs["bclassFullName"]
		//m_pDocMO.signatureHash = attrs["signatureHash"]
		m_pDocMO.inDate = Utils.getDateFromString(attrs["inDate"])
		var csc = 0
		if let strCSC = attrs["controlStateCode"]
		{
			if strCSC == "Control" {csc = 1}
			else if strCSC == "Special" {csc = 2}
		}
		m_pDocMO.controlStateCode = csc

		let elemChilds = elem.children
		if let author = elemChilds.filter({ $0.name == "author" }).first
		{
			m_pDocMO.author = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, author, false, false)
		}
		
		if let contact = elemChilds.filter({ $0.name == "contact" }).first
		{
			m_pDocMO.contact = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, contact, false, false)
		}
		
		/*if let addressees = elemChilds.filter({ $0.name == "addressees" }).first?.children.filter({ $0.name == "item" })
		{
			m_pDocMO.parseAddressees(addressees,"contact")
		}*/
	}
	
	func setDocVisibilityAndUpdateVersion()
	{
		m_pDocMO.version = m_docVersion
		m_pDocMO.visible = true
		
		CoreDataManager.sharedInstance.saveContext(m_pMocDoc)
	}
}
