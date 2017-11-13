//
//  GlobDat.swift
//  DoXSw
//
//  Created by nick on 20/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import UIKit

final class GlobDat
{
	static let EClassNameAgreeDocument = "Docflow.References.AgreeDocument"
	static let EClassNameApprovalDocument = "Docflow.References.ApprovalDocument"
	static let EClassNameReviewDocument = "Docflow.References.ReviewDocument"
	static let EClassNameExecution = "Workflow.References.FormalTask"
	static let EClassNameTaskReadDocument = "Workflow.References.InspectionTask"
	static let EClassNameReadDocument = "EClassNameReadDocument"
	//static let EClassNameAcceptExecution = "EClassNameAcceptExecution"

	static var eClass_WorkflowReferencesFormalTask = 0
	static var eClass_DocflowReferencesAgreeDocument = 0
	static var eClass_DocflowReferencesApproveDocument = 0
	static var eClass_DocflowReferencesReviewDocument = 0
	static var eClass_DocflowTaskReadDocument = 0
	static var eClass_ReadDocument = 0
	static var eClass_AcceptExecution = 0

	static let kSynchErrorCritical = "SynchErrorCritical"
	static let kAuthorizationFailed = "AuthorizationFailed"
	static let kRequestInGroupCompleted = "RequestInGroupCompleted"
	static let kEClassLoaded = "EClassLoaded"
	static let kSynchErrorLoggableDownload = "SynchErrorLoggableDownload"
	static let kNewRequestsGroup = "NewRequestsGroup"
	static let kRemoveFromDeleteContact = "RemoveFromDeleteContact"
	static let kRemoveFromDeleteFavorite = "RemoveFromDeleteFavorite"
	static let kRemoveFromDeleteAffilate = "RemoveFromDeleteAffilate"
	static let kUpdateButtonProgress = "UpdateButtonProgress"
	static let kDocListLoaded = "DocListLoaded"
	static let kGroup1DocCount = "Group1DocCount"
	static let kGroup2DocCount = "Group2DocCount"
	static let kGroup3DocCount = "Group3DocCount"
	static let kGroup1DocArrived = "Group1DocArrived"
	static let kGroup2DocArrived = "Group2DocArrived"
	static let kGroup3DocArrived = "Group3DocArrived"
	static let kRemoveFromDeleteDoc = "RemoveFromDeleteDoc"
	static let kAddToDownloadedDoc = "AddToDownloadedDoc"
	static let kDocArrived = "DocArrived"
	static let kDocDeleted = "DocDeleted"
	static let kDocMoved = "DocMoved"
	static let kDocTaskArrived = "DocTaskArrived"
	static let kDocTaskDeleted = "DocTaskDeleted"
	static let kDocTasksUpdated = "DocTasksUpdated"
	static let kPresentationsDownloaded = "PresentationsDownloaded"
	static let kDocumentAccepted = "DocumentAccepted"
	static let kRemoveFromDeleteAtt = "RemoveFromDeleteAtt"
	static let kSynchronizationPortion = "SynchronizationPortion"
	static let kSynchronizationFinished = "SynchronizationFinished"
	static let kTaskReadConfirmed = "TaskReadConfirmed"
	static let kProgressOriginShouldChange = "ProgressOriginShouldChange"
	static let kNavigationTitleChanged = "NavigationTitleChanged"
	static let kUnprocessedDocsCounter = "UnprocessedDocsCounter"
	static let kUnreadDocsCounter = "UnreadDocsCounter"
	static let kDocFolderSelected = "DocFolderSelected"
	static let kDocFolderListChanged = "DocFolderListChanged"
	static let kDocHaveBeenRead = "DocHaveBeenRead"
	static let kDocAttSelected = "DocAttSelected"

	static let kKey_MaxDocCount = "Key_MaxDocCount"
	static let kKey_MaxAttMb = "Key_MaxAttMb"
	static let kKey_ShowExecutionDate = "Key_ShowExecutionDate"
	static let kKey_SwitchOffSogl = "Key_SwitchOffSogl"
	static let kKey_SwitchOffPodpis = "Key_SwitchOffPodpis"
	static let kKey_SwitchOffRassmotr = "Key_SwitchOffRassmotr"
	static let kKey_SwitchOffExec = "Key_SwitchOffExec"
	static let kKey_SwitchOffAcceptExec = "Key_SwitchOffAcceptExec"
	static let kKey_SwitchOffRead = "Key_SwitchOffRead"

	static let kKey_ServerName = "Key_ServerName"
	static let kKey_ServerPort = "Key_ServerPort"
	static let kKey_ApplicationName = "Key_ApplicationName"
	static let kKey_SSLEnable = "Key_SSLEnable"
	static let kKey_ResourceName = "Key_ResourceName"
	static let kKey_UserName = "Key_UserName"
	static let kKey_RoleId = "Key_RoleId"
	static let kKey_Password = "Key_Password"

	static var bDoLogin = true
	static var deviceUserContactId = 0
	static var bIsBoss = false
	static var bDisableCheckDocumentVersion = true
	static var curDocId = 0
	static var curTask = 0

	static let cxNavItem = 44
	static let gapNavItem = 10
}
