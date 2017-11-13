//
//  EClasses.swift
//  DoXSw
//
//  Created by nick on 19/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class EClasses
{
	final class EClassObject
	{
		var m_EClassId = 0
		var m_EClassButtonName:String = ""
		var m_EClassIcon:String = ""
	}

	static private var m_EClassObjects:[EClassObject] = []

	static func count() -> Int
	{
		return m_EClassObjects.count
	}

	static func getId(_ idx:Int) -> Int
	{
		return m_EClassObjects[idx].m_EClassId
	}

	static func getEClassButtonNameByEClasId(_ idEClass:Int) -> String
	{
		if let element = m_EClassObjects.filter({$0.m_EClassId == idEClass}).first
		{
			return element.m_EClassButtonName
		}
		return ""
	}

	static func getIndexByEClasId(_ idEClass:Int) -> Int
	{
		for i in 0..<m_EClassObjects.count
		{
			if m_EClassObjects[i].m_EClassId == idEClass {return i}
		}
		return -1
	}

	static func getButtonName(_ idx:Int) -> String
	{
		return m_EClassObjects[idx].m_EClassButtonName
	}

	static func getIconName(_ idx:Int) -> String
	{
		return m_EClassObjects[idx].m_EClassIcon
	}

	static func reset()
	{
		m_EClassObjects = []
	}

	static func loadFromStore()
	{
		if m_EClassObjects.count == 0
		{
			let cdm:CoreDataManager = CoreDataManager.sharedInstance
			let moc:NSManagedObjectContext = cdm.createWorkerContext()
			let req:NSFetchRequest<EClassMO> = .init(entityName:"EClass")

			let order = [GlobDat.EClassNameAgreeDocument,GlobDat.EClassNameApprovalDocument,GlobDat.EClassNameReviewDocument,GlobDat.EClassNameExecution,GlobDat.EClassNameTaskReadDocument]
			let images = ["NaSoglosovanie.png","NaPodpis.png","NaRassmotrenie.png","NaRassmotrenie.png","NaRassmotrenie.png"]
			let buttonNames = ["ForAgreement".localized,"ForReview".localized,"ForApproval".localized,"ForExecution".localized,"ForTaskRead".localized]
			var eClassIdMax = 0

			do
			{
				let eClassRecords:[EClassMO] = try moc.fetch(req)
				for i in 0..<order.count
				{
					if let pRec = eClassRecords.filter({$0.fullName == order[i]}).first
					{
						let pObj = EClassObject()
						pObj.m_EClassId = pRec.eclassId
						pObj.m_EClassButtonName = buttonNames[i]
						pObj.m_EClassIcon = images[i]
						m_EClassObjects.append(pObj)
						eClassIdMax = max(eClassIdMax,pRec.eclassId)
					}
				}
				if let pRec = eClassRecords.filter({$0.fullName == GlobDat.EClassNameExecution}).first
				{
					GlobDat.eClass_WorkflowReferencesFormalTask = pRec.eclassId
				}
				if let pRec = eClassRecords.filter({$0.fullName == GlobDat.EClassNameAgreeDocument}).first
				{
					GlobDat.eClass_DocflowReferencesAgreeDocument = pRec.eclassId
				}
				if let pRec = eClassRecords.filter({$0.fullName == GlobDat.EClassNameApprovalDocument}).first
				{
					GlobDat.eClass_DocflowReferencesApproveDocument = pRec.eclassId
				}
				if let pRec = eClassRecords.filter({$0.fullName == GlobDat.EClassNameReviewDocument}).first
				{
					GlobDat.eClass_DocflowReferencesReviewDocument = pRec.eclassId
				}
				if let pRec = eClassRecords.filter({$0.fullName == GlobDat.EClassNameTaskReadDocument}).first
				{
					GlobDat.eClass_DocflowTaskReadDocument = pRec.eclassId
				}

				if eClassRecords.count > 0
				{
					//adding pseudo eclass for documents for reading
					let pObj = EClassObject()
					GlobDat.eClass_ReadDocument = eClassIdMax + 1
					pObj.m_EClassId = GlobDat.eClass_ReadDocument
					pObj.m_EClassButtonName = "ForAcquaintance".localized
					pObj.m_EClassIcon = ""
					m_EClassObjects.append(pObj)

					//adding pseudo eclass for documents for Accept Execution
					let pObj2 = EClassObject()
					GlobDat.eClass_AcceptExecution = GlobDat.eClass_ReadDocument + 1
					pObj2.m_EClassId = GlobDat.eClass_AcceptExecution
					pObj2.m_EClassButtonName = "ForAcceptExecution".localized
					pObj2.m_EClassIcon = "NaRassmotrenie.png"
					m_EClassObjects.append(pObj2)
				}
			}
			catch
			{
				print(error)
			}
		}
	}
}
