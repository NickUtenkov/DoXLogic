//
//  Downloader_Doc.swift
//  DoXSw
//
//  Created by nick on 27/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class Downloader_Doc : DataDownloader
{
	private var m_docId = 0,m_docVersion = 0
	private var m_pDocMO:DocMO
	private var m_pMocDoc:NSManagedObjectContext
	private var m_bAcceptDocument:Bool = false
	private var m_requestContact:NSFetchRequest<ContactMO>
	private var m_requestDocument:NSFetchRequest<DocMO>
	private var m_attsToDownload:[AttDownloadInfo] = []
	private var outInformNotDownloaded:NSMutableArray = NSMutableArray()
	private var m_taskObjsToDelete:[TaskUnprocessed] = []
	private var nAttMaxSize:UInt64 = 0
	private var m_pAdditionalDocsForDownload:[DocMO] = []

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

		if let elem = doc?.root["body"]["getDocumentsList"]["item"]
		{
			parseDocument(elem)
			if let docTasks = elem.children.filter({ $0.name == "documentTasks" }).first?.children.filter({ $0.name == "item" })
			{
				parseTasks(docTasks)
			}
			if m_bAcceptDocument
			{
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

				//if (bDownloadLinkedDocs) [self parseDocLinks:documentNode]
				if let docFiles = docChilds.filter({ $0.name == "files" }).first?.children.filter({ $0.name == "item" })
				{
					let selAdd = #selector(m_pDocMO.addToAttSet as (_ value: DocContentMO) -> Void)
					let selRemove = #selector(m_pDocMO.removeFromAttSet as (_ value: DocContentMO) -> Void) 
					Utils.parseFiles(docFiles,&m_attsToDownload,m_pDocMO,m_pDocMO.attSet,selAdd,selRemove,nAttMaxSize,outInformNotDownloaded)
					Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
				}
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocumentAccepted),object:nil)
			}
			else {deleteDocumentTasks()}

			CoreDataManager.sharedInstance.saveContext(m_pMocDoc)

			if m_bAcceptDocument
			{
				var bAttsDownloaded = true
				if m_attsToDownload.count > 0
				{
					let pAttachmentsDownloader = Downloader_Attachments(m_attsToDownload)
					pAttachmentsDownloader.start()
					bAttsDownloaded = pAttachmentsDownloader.finishOK()
				}
				let bAdditDownloaded = true
				if bAttsDownloaded && bAdditDownloaded
				{
					//t0 = mach_absolute_time()
					setDocVisibilityAndUpdateVersion()
					//parseTime += m_nanoTime.GetSecondsSince(t0)
					NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kSynchronizationPortion),object:nil)
				}
			}
		}
	}

	func setDocVisibilityAndUpdateVersion()
	{
		m_pDocMO.version = m_docVersion
		m_pDocMO.visible = true
		
		CoreDataManager.sharedInstance.saveContext(m_pMocDoc)
	}

	func deleteDocumentTasks()
	{
		let selRemoveTask = #selector(m_pDocMO.removeFromTasks as (_ value: TaskUnprocessed) -> Void)
		CorDatFuncs.removeRelationshipObjects(m_pDocMO,m_pDocMO.tasks!,selRemoveTask,true)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocDeleted),object:m_docId                       )
	}

	func parseDocument(_ elem:AEXMLElement)
	{
		let attrs = elem.attributes
		m_docId = Int(attrs["id"]!)!
		//print("m_docId",m_docId)
		for pTask in m_pDocMO.tasks! {m_taskObjsToDelete.append(pTask)}

		m_docVersion = XMLFuncs.getVersionFromAttrs(attrs)
		if let strPrior = attrs["priority"] {m_pDocMO.priority = strPrior.bool}
		m_pDocMO.docTitle = attrs["name"]
		m_pDocMO.docket = attrs["docket"]
		m_pDocMO.inRegistration = attrs["inRegistration"]
		m_pDocMO.type = attrs["documentType"]
		m_pDocMO.eclass = attrs["eclass"]
		m_pDocMO.fullNameOfBClass = attrs["bclassFullName"]
		m_pDocMO.signatureHash = attrs["signatureHash"]
		m_pDocMO.inDate = Utils.getDateFromString(attrs["inDate"])
		var csc = 0
		if let strCSC = attrs["controlStateCode"]
		{
			if strCSC == "Control" {csc = 1}
			else if strCSC == "Special" {csc = 2}
		}
		m_pDocMO.controlStateCode = csc
		if csc != 0
		{
			m_pDocMO.controlDate = Utils.getDateFromString(attrs["controlDate"])
		}

		let elemChilds = elem.children
		if let author = elemChilds.filter({ $0.name == "author" }).first
		{
			m_pDocMO.author = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, author, false, false)
		}

		if let contact = elemChilds.filter({ $0.name == "contact" }).first
		{
			m_pDocMO.contact = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, contact, false, false)
		}

		if let addressees = elemChilds.filter({ $0.name == "addressees" }).first?.children.filter({ $0.name == "item" })
		{
			m_pDocMO.parseAddressees(addressees,"contact")
		}
	}

	func parseTasks(_ docTasks:[AEXMLElement])
	{
		var bHaveAcceptExec = false
		var taskIdAcceptExec:Set<Int> = []
		m_bAcceptDocument = false

		for docTask in docTasks
		{
			if let attrAE = docTask.attributes["isCanReview"]
			{
				if attrAE.bool
				{
					bHaveAcceptExec = true
					taskIdAcceptExec.insert(Int(docTask.attributes["id"]!)!)
				}
			}
		}

		var cTasksInserted = 0
		for docTask in docTasks
		{
			var bCanComplete = false
			var bExistingTask = false,bWasConsolidated = false
			var executorId:ContactMO? = nil,coExecutorId:ContactMO? = nil
			let attrs = docTask.attributes
			let docTaskElements = docTask.children

			if let executor = docTaskElements.filter({ $0.name == "executor" }).first
			{
				executorId = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, executor, false, false)
			}

			if let executor = docTaskElements.filter({ $0.name == "coexecutor" }).first
			{
				coExecutorId = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, executor, false, false)
			}

			if let strCanComplete = attrs["isCanComplete"]
			{
				bCanComplete = strCanComplete.bool
			}

			var childItems:[AEXMLElement] = []
			if let childItemsTmp = docTaskElements.filter({ $0.name == "childs" }).first?.children.filter({ $0.name == "item" })
			{
				childItems = childItemsTmp
			}
			if !bCanComplete
			{
				var cGoodChild = 0
				for childElem in childItems
				{
					if let taskState = childElem.attributes["state"]
					{
						if taskState == TaskStates.tsClose {cGoodChild += 1}
						else if taskState == TaskStates.tsCancel {cGoodChild += 1}
						else if taskState == TaskStates.tsReject {cGoodChild += 1}
						else if taskState == TaskStates.tsCreate {cGoodChild += 1}
						else if taskState == TaskStates.tsArchive {cGoodChild += 1}
					}
				}
				if cGoodChild == childItems.count {bCanComplete = true}
			}

			var datePlanEnd:Date? = nil
			if let strDPE = attrs["datePlanEnd"]
			{
				datePlanEnd = Utils.getDateFromString(strDPE)
			}

			let strDateFactEnd:String? = attrs["dateFactEnd"]

			var bAcceptExecution = false 
			if let attrAE = docTask.attributes["isCanReview"]
			{
				bAcceptExecution = attrAE.bool
			}

			let taskId1 = Int(docTask.attributes["id"]!)!
			let bTaskToDeviceUser = (((executorId != nil) && (executorId!.employeeId == GlobDat.deviceUserContactId)) || ((coExecutorId != nil) && (coExecutorId!.employeeId == GlobDat.deviceUserContactId)))
			if bTaskToDeviceUser && bCanComplete && (strDateFactEnd == nil) {m_bAcceptDocument = true}
			if !m_bAcceptDocument {m_bAcceptDocument = bAcceptExecution}
			if bTaskToDeviceUser && !bCanComplete && (datePlanEnd == nil)
			{
				continue//not adding new task to store(or will delete existing)
			}

			var pTask:TaskUnprocessed
			let idx = m_pDocMO.tasks!.index(where:{$0.taskId == taskId1})
			if idx == nil
			{
				pTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: m_pMocDoc) as! TaskUnprocessed
				pTask.taskId = taskId1
				pTask.docId = m_docId
				m_pDocMO.addToTasks(pTask)
				if GlobDat.curTask == taskId1 {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocTaskArrived),object:nil)}
				cTasksInserted += 1
			}
			else
			{
				bExistingTask = true
				pTask = m_pDocMO.tasks![idx!]
				bWasConsolidated = pTask.consolidated
				pTask.resetOutputOrReportFiles()
				//removeIfNumberFound([NSNumber numberWithInt:taskId1],m_uploadOperationsErrors)//redo NSNumber
			}

			pTask.eclassId = Int(attrs["eclass"]!)!
			if !bAcceptExecution
			{
				if (pTask.taskProcessed != nil) && pTask.acceptExecution
				{
					pTask.deleteProcessedTask(false)
				}
			}
			pTask.acceptExecution = bAcceptExecution

			let bIsRassmotrenie = (pTask.eclassId == GlobDat.eClass_WorkflowReferencesFormalTask) || (pTask.eclassId == GlobDat.eClass_DocflowReferencesReviewDocument)

			if let author = docTaskElements.filter({ $0.name == "author" }).first
			{
				pTask.author = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, author, false, false)
			}
			
			if let controller = docTaskElements.filter({ $0.name == "controller" }).first
			{
				pTask.controller = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, controller, false, false)
			}

			pTask.canComplete = bCanComplete
			if let strResult = attrs["result"]
			{
				pTask.result = strResult.bool as NSNumber?
			}

			pTask.report = attrs["report"]
			pTask.state = attrs["state"]
			if datePlanEnd != nil {pTask.datePlanEnd = datePlanEnd}
			if strDateFactEnd != nil
			{
				if (pTask.taskProcessed != nil) && !(pTask.dateFactEnd != nil)
				{
					pTask.deleteProcessedTask(false)
				}
				pTask.dateFactEnd = Utils.getDateFromString(strDateFactEnd)
			}

			if let strDD = attrs["dateDeliver"]
			{
				pTask.dateDeliver = Utils.getDateFromString(strDD)
			}

			pTask.executor = executorId//found above
			pTask.coexecutor = coExecutorId//found above

			pTask.reworkReason = attrs["reworkReason"]
			pTask.reworkDescription = attrs["reworkDescription"]

			var resolutionsBefore = Array(pTask.resolutionsSet!)
			if let forwards = docTaskElements.filter({ $0.name == "forwards" }).first?.children.filter({ $0.name == "item" })
			{
				var nResolution = -1
				for forward in forwards
				{
					nResolution += 1
					let attrsFwd = forward.attributes
					let fwdId = Int(attrsFwd["id"]!)!
					var pResolutionRec:ResolutionMO
					let idx = resolutionsBefore.index(where:{$0.forwardId == fwdId})
					if idx == nil
					{
						pResolutionRec = NSEntityDescription.insertNewObject(forEntityName: "Resolution", into: m_pMocDoc) as! ResolutionMO
						pResolutionRec.forwardId = fwdId
						pTask.addToResolutionsSet(pResolutionRec)
					}
					else
					{
						pResolutionRec = resolutionsBefore[idx!]
						resolutionsBefore.remove(at: idx!)
					}
					pResolutionRec.datePlanEnd = Utils.getDateFromString(attrsFwd["datePlanEnd"])
					pResolutionRec.text = attrsFwd["description"]
					pResolutionRec.responsible = nil
					pResolutionRec.resolutionNumber = nResolution

					let fwdElems = forward.children

					if let controller = fwdElems.filter({ $0.name == "controller" }).first
					{
						pResolutionRec.controller = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, controller, false, false)
					}

					if let author = fwdElems.filter({ $0.name == "author" }).first
					{
						pResolutionRec.author = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, author, false, false)
					}

					var resExecutorsBefore = Array(pResolutionRec.executorsSet!)
					if let resExecutors = fwdElems.filter({ $0.name == "executors" }).first?.children.filter({ $0.name == "item" })
					{
						for resExecutor in resExecutors
						{
							let pResExecutor = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, resExecutor, false, false)
							let idx = resExecutorsBefore.index(where:{$0.employeeId == pResExecutor.employeeId})
							if idx == nil {pResolutionRec.addToExecutorsSet(pResExecutor)}
							else {resExecutorsBefore.remove(at: idx!)}
						}
					}
					for pCon in resExecutorsBefore
					{
						pResolutionRec.removeFromExecutorsSet(pCon)
						m_pMocDoc.delete(pCon)
					}
				}
			}
			for pRes in resolutionsBefore
			{
				pTask.removeFromResolutionsSet(pRes)
				m_pMocDoc.delete(pRes)
			}

			var childTasksBefore = Array(pTask.childTasksSet!)
			for childElem in childItems
			{
				let attrsChild = childElem.attributes
				let idVal = Int(attrsChild["id"]!)!

				let childChildren = childElem.children

				var pChildTaskRec:ChildTaskMO
				let idx = childTasksBefore.index(where:{$0.taskId == idVal})
				if idx == nil
				{
					pChildTaskRec = NSEntityDescription.insertNewObject(forEntityName: "ChildTask", into: m_pMocDoc) as! ChildTaskMO
					pChildTaskRec.taskId = idVal
					pTask.addToChildTasksSet(pChildTaskRec)
				}
				else
				{
					pChildTaskRec = childTasksBefore[idx!]
					childTasksBefore.remove(at: idx!)
				}

				pChildTaskRec.dateFactEnd = Utils.getDateFromString(attrsChild["dateFactEnd"])
				pChildTaskRec.datePlanEnd = Utils.getDateFromString(attrsChild["datePlanEnd"])
				pChildTaskRec.taskDescription = attrsChild["description"]
				pChildTaskRec.state = attrsChild["state"]
				pChildTaskRec.report = attrsChild["report"]
				if let strResult = attrsChild["result"]
				{
					pChildTaskRec.approved = strResult.bool as NSNumber!
				}

				var bChildIsCanReview = false
				if bHaveAcceptExec && (taskIdAcceptExec.contains(idVal)) {bChildIsCanReview = true}
				pChildTaskRec.isCanReview = bChildIsCanReview

				var childExecutorsBefore = Array(pChildTaskRec.executorsSet!)
				if let childExecutors = childChildren.filter({ $0.name == "executors" }).first?.children.filter({ $0.name == "item" })
				{
					for childExecutor in childExecutors
					{
						let pExec = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, childExecutor, false, false)
						let idx = childExecutorsBefore.index(where:{$0.employeeId == pExec.employeeId})
						if idx == nil {pChildTaskRec.addToExecutorsSet(pExec)}
						else {childExecutorsBefore.remove(at: idx!)}
					}
				}
				for pCon in childExecutorsBefore
				{
					pChildTaskRec.removeFromExecutorsSet(pCon)
					m_pMocDoc.delete(pCon)
				}
				
				if let author = childChildren.filter({ $0.name == "author" }).first
				{
					pChildTaskRec.author = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, author, false, false)
				}
				if !m_bAcceptDocument {m_bAcceptDocument = (pChildTaskRec.author != nil)}
				if !bCanComplete && (pChildTaskRec.author != nil) && bIsRassmotrenie {pTask.consolidated = true}
				
				if let controller = childChildren.filter({ $0.name == "controller" }).first
				{
					pChildTaskRec.controller = CorDatFuncs.addContact(m_pMocDoc, m_requestContact, controller, false, false)
				}

				var childDocsBefore = Array(pChildTaskRec.docSet!)
				if let childTaskDocs = childChildren.filter({ $0.name == "outputDocuments" }).first?.children.filter({ $0.name == "item" })
				{
					for childTaskDoc in childTaskDocs
					{
						let childTaskDocAttrs = childTaskDoc.attributes
						let childDocId = Int(childTaskDocAttrs["id"]!)!
						let version = XMLFuncs.getVersionFromAttrs(childTaskDocAttrs)
						let pDocMO:DocMO
						var docVersionInDB = 0
						if let pDocMO1:DocMO = CorDatFuncs.fetchOneRecord(NSPredicate(format:"docId==%d",childDocId),DocMO.fetchRequest(),m_pMocDoc)
						{
							pDocMO = pDocMO1
							docVersionInDB = pDocMO1.version
						}
						else
						{
							pDocMO = NSEntityDescription.insertNewObject(forEntityName: "Document", into: m_pMocDoc) as! DocMO
							pDocMO.docId = childDocId
							pDocMO.visible = false
							pDocMO.version = 0
							if GlobDat.curDocId == childDocId {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocArrived),object:nil)}
						}
						let idx = childDocsBefore.index(where:{$0.docId == childDocId})
						if idx == nil {pChildTaskRec.addToDocSet(pDocMO)}
						else {childDocsBefore.remove(at: idx!)}

						if GlobDat.bDisableCheckDocumentVersion || (docVersionInDB < version)
						{
							//BOOL bDocFound = [Synchronizer_v3610 findAlreadyDownloadedDocInCurrentSynchronization:childDocId]
							//if (!bDocFound) [m_pAdditionalDocsForDownload addObject:pDocMO]
							m_pAdditionalDocsForDownload.append(pDocMO)
						}
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kRemoveFromDeleteDoc),object:childDocId)
						NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kAddToDownloadedDoc),object:childDocId)
					}
				}
				for pDoc in childDocsBefore
				{
					pChildTaskRec.removeFromDocSet(pDoc)
					m_pMocDoc.delete(pDoc)
				}

				if let outputFiles = childChildren.filter({ $0.name == "outputFiles" }).first?.children.filter({ $0.name == "item" })
				{
					let selAdd = #selector(pChildTaskRec.addToOutputFiles as (_ value: DocContentMO) -> Void)
					let selRemove = #selector(pChildTaskRec.removeFromOutputFiles as (_ value: DocContentMO) -> Void) 
					Utils.parseFiles(outputFiles,&m_attsToDownload,pChildTaskRec,pChildTaskRec.outputFiles,selAdd,selRemove,nAttMaxSize,outInformNotDownloaded)
				}
				Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
				if let reportFiles = childChildren.filter({ $0.name == "reportFiles" }).first?.children.filter({ $0.name == "item" })
				{
					let selAdd = #selector(pChildTaskRec.addToReportFiles as (_ value: DocContentMO) -> Void)
					let selRemove = #selector(pChildTaskRec.removeFromReportFiles as (_ value: DocContentMO) -> Void) 
					Utils.parseFiles(reportFiles,&m_attsToDownload,pChildTaskRec,pChildTaskRec.reportFiles,selAdd,selRemove,nAttMaxSize,outInformNotDownloaded)
				}
				Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
			}
			for pChildTaskRec in childTasksBefore
			{
				pTask.removeFromChildTasksSet(pChildTaskRec)
				m_pMocDoc.delete(pChildTaskRec)
			}
			
			if pTask.consolidated && bCanComplete {pTask.consolidated = false}
			if bExistingTask && !bWasConsolidated && pTask.consolidated//changed hypostasis
			{
				pTask.deleteProcessedTask(false)
				//NSFileManager *defFM = [NSFileManager defaultManager]
				//NSError *error = nil
				//[defFM removeItemAtPath:createUpdateTaskFilesWasSentFilePathString(taskId1) error:&error]
				//[defFM removeItemAtPath:createArchiveWasUploadedFilePathString(taskId1) error:&error]
				//[defFM removeItemAtPath:createArchiveFilePathString(taskId1) error:&error]
				//[defFM removeItemAtPath:createAudioFilePathString(taskId1) error:&error]
				//[defFM removeItemAtPath:createScribbleFilePathString(taskId1) error:&error]
			}
			
			pTask.fullNameOfBClass = attrs["bclassFullName"]
			pTask.taskDescription = attrs["description"]
			pTask.name = attrs["name"]

			if let strSignatureNeeded = attrs["isSignatureNeeded"]
			{
				pTask.shouldSignTask = strSignatureNeeded.bool
			}
			if let strSignedDocument = attrs["isSignedDocument"]
			{
				pTask.shouldSignDocument = strSignedDocument.bool
			}

			if let inputDocuments = docTaskElements.filter({ $0.name == "inputDocuments" }).first?.children.filter({ $0.name == "item" })
			{
				let selAdd = #selector(pTask.addToInputDocuments as (_ value: LinkedMO) -> Void)
				let selRemove = #selector(pTask.removeFromInputDocuments as (_ value: LinkedMO) -> Void) 
				CorDatFuncs.updateLinkedObjects(inputDocuments,pTask,pTask.inputDocuments!,selAdd,selRemove,0)
			}
			if let inputFiles = docTaskElements.filter({ $0.name == "inputFiles" }).first?.children.filter({ $0.name == "item" })
			{
				let selAdd = #selector(pTask.addToInputFiles as (_ value: LinkedMO) -> Void)
				let selRemove = #selector(pTask.removeFromInputFiles as (_ value: LinkedMO) -> Void) 
				CorDatFuncs.updateLinkedObjects(inputFiles,pTask,pTask.inputFiles!,selAdd,selRemove,0)
			}
			let outputDocuments = docTaskElements.filter({ $0.name == "outputDocuments" }).first?.children.filter({ $0.name == "item" })
			if outputDocuments != nil
			{
				let selAdd = #selector(pTask.addToOutputDocSet as (_ value: LinkedMO) -> Void)
				let selRemove = #selector(pTask.removeFromOutputDocSet as (_ value: LinkedMO) -> Void) 
				CorDatFuncs.updateLinkedObjects(outputDocuments!,pTask,pTask.outputDocSet!,selAdd,selRemove,1)
			}
			let outputFiles = docTaskElements.filter({ $0.name == "outputFiles" }).first?.children.filter({ $0.name == "item" })
			if outputFiles != nil
			{
				let selAdd = #selector(pTask.addToOutputFiles as (_ value: LinkedMO) -> Void)
				let selRemove = #selector(pTask.removeFromOutputFiles as (_ value: LinkedMO) -> Void) 
				CorDatFuncs.updateLinkedObjects(outputFiles!,pTask,pTask.outputFiles!,selAdd,selRemove,2)
			}
			let reportFiles = docTaskElements.filter({ $0.name == "reportFiles" }).first?.children.filter({ $0.name == "item" })
			if reportFiles != nil
			{
				let selAdd = #selector(pTask.addToReportFiles as (_ value: LinkedMO) -> Void)
				let selRemove = #selector(pTask.removeFromReportFiles as (_ value: LinkedMO) -> Void) 
				CorDatFuncs.updateLinkedObjects(reportFiles!,pTask,pTask.reportFiles!,selAdd,selRemove,2)
			}

			//if (outDocsElements && [outDocsElements count]) [self addDownloadingOutputDocuments:[outDocsElements objectAtIndex:0]]
			if outputFiles != nil {Utils.parseFiles(outputFiles!,&m_attsToDownload,m_pDocMO,nil,nil,nil,nAttMaxSize,outInformNotDownloaded)}
			Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
			if reportFiles != nil {Utils.parseFiles(reportFiles!,&m_attsToDownload,m_pDocMO,nil,nil,nil,nAttMaxSize,outInformNotDownloaded)}
			Utils.informNotDownloaded(outInformNotDownloaded,m_pDocMO)
			
			if let idx = m_taskObjsToDelete.index(where:{$0.taskId == pTask.taskId})
			{
				m_taskObjsToDelete.remove(at: idx)
			}
		}
		
		for pToDelete in m_taskObjsToDelete
		{
			if (GlobDat.curDocId == m_docId) && (pToDelete.taskId == GlobDat.curTask)
			{
				NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocTaskDeleted),object:pToDelete)
			}
			else {m_pDocMO.removeFromTasks(pToDelete)}
		}
		if (GlobDat.curDocId == m_docId) && ((cTasksInserted != 0) || (m_taskObjsToDelete.count > 0))
		{
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocTasksUpdated),object:nil)
		}
		m_taskObjsToDelete.removeAll()
	}
}
