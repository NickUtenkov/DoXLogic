//
//  AcquListViewController.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 07/01/17.
//  Copyright © 2017 Nick Utenkov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class AcquListViewController : MyVC
{
	@IBOutlet var m_slidingFolders:SlidingView!
	@IBOutlet weak var m_pDocsListViewTableAcquintance:UITableView!
	@IBOutlet weak var m_pFoldersTable:UITableView!
	@IBOutlet var m_pAcquaintanceFolders:AcquaintanceFolders!

	private var m_AcquaintanceFolderId = 0
	private var m_bInsideSlidingFolders = false,m_bSlidingFoldersStateBeforeMoveIsLocked = false
	private var m_touchBeganPointGlobal = CGPoint.zero
	private var m_bMoveProcessed = false
	fileprivate var m_DocList:[DocMO] = []
	fileprivate var m_indexes:[Int] = []
	private var m_counterAllUnread = 0,m_cSelected = 0

	private var m_imgUrgent:UIImage?,m_imgStamp:UIImage?,m_imgBadge:UIImage?
	fileprivate var m_imgMarkedOn:UIImage?,m_imgMarkedOff:UIImage?

	private var m_navTitle = ""
	private var originForProgress:CGFloat = 0.0
	private let AllDocsFolderId = -1
	private let NoFolderSelectedId = 0

	var m_moc:NSManagedObjectContext?

	private var tableRowH:CGFloat = 0
	private var ctx1 = 0
	private var ourWidth:CGFloat = 0
	lazy var pseudoTask:TaskInfo =
	{
			let pseudoTask = TaskInfo(nil)
			pseudoTask.displayEClassId = GlobDat.eClass_AcceptExecution
			return pseudoTask
	}()
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.docFolderSelected), name:NSNotification.Name(rawValue:GlobDat.kDocFolderSelected), object:nil)
		nc.addObserver(self, selector:#selector(self.resizeFolderSliding), name:NSNotification.Name(rawValue:GlobDat.kDocFolderListChanged), object:nil)
		nc.addObserver(self, selector:#selector(self.processDocHaveBeenRead), name:NSNotification.Name(rawValue:GlobDat.kDocHaveBeenRead), object:nil)
		
		m_navTitle = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as! String
		if UserDefaults.standard.object(forKey:Utils.createUniq_pressedAcquFolderIdKey()) == nil
		{
			Utils.prefsSet(-100,Utils.createUniq_pressedAcquFolderIdKey())
		}
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if context == &ctx1
		{
			if ourWidth != self.view.frame.size.width
			{
				ourWidth = self.view.frame.size.width
				refreshTable()
				resizeDocsListTable()
				m_pAcquaintanceFolders.refreshFolders()
			}
		}
	}
	
	deinit
	{
		NotificationCenter.`default`.removeObserver(self)
		self.view.removeObserver(self, forKeyPath: "frame", context: &ctx1)
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()

		m_pDocsListViewTableAcquintance.rowHeight = UITableViewAutomaticDimension
		m_pDocsListViewTableAcquintance.estimatedRowHeight = 140
		
		m_imgUrgent = UIImage(named:"Urgent.png")
		m_imgStamp = UIImage(named:"StampCtrl.png")
		m_imgBadge = UIImage(named:"badge_blue13")
		m_imgMarkedOn = UIImage(named:"marked_on")
		m_imgMarkedOff = UIImage(named:"marked_off")
		
		m_pAcquaintanceFolders.m_moc = m_moc
		tableRowH = m_pAcquaintanceFolders.getRowH()//should be here(in case empty list)
		m_pAcquaintanceFolders.createFoldersList()

		m_slidingFolders.didLoad()
		m_slidingFolders.m_LabelNames = ["Folders".localized,"Lock".localized,"Unlock".localized]
		m_slidingFolders.m_LabelSigns = ["\u{2162}","\u{2192}","\u{2190}",""]
		m_slidingFolders.m_BackImage = UIImage(named:"slider_folders_selected.png")
		m_slidingFolders.funcContentWidthChanged = {[unowned self] in self.updateFoldersTableWidthAndOrigin()}
		m_slidingFolders.funcHeightChanged = {[unowned self] in self.updateFoldersTouchAreaBackgroundColor()}

		m_slidingFolders.m_stateLockedPrefsKey = Utils.createUniq_AcquLockedKey()
		let bFoldersLocked = Utils.prefsGetBool(m_slidingFolders.m_stateLockedPrefsKey)
		if !bFoldersLocked
		{
			m_slidingFolders.setInitialOriginX(self.view.frame.size.width)
			m_pAcquaintanceFolders.tableView.setXOrigin(m_slidingFolders.getTouchWidth()+5)
		}
		else
		{
			m_slidingFolders.setState(SlidingView.State.stateLocked)
			animateSlidingFolders(0,0.5)
			updateFoldersTableWidthAndOrigin()
			m_pAcquaintanceFolders.tableView.setXOrigin(+5)
		}
		
		m_pAcquaintanceFolders.m_currentFolderId = m_AcquaintanceFolderId
		m_slidingFolders.m_View.addSubview(m_pAcquaintanceFolders.tableView)
		
		loadAllDocumentsList()
		updateAllFoldersCounters()
		m_pAcquaintanceFolders.refreshFolders()

		self.view.addObserver(self, forKeyPath:"frame", options: .new, context:&ctx1)
	}

	override func viewDidAppear(_ animated:Bool)
	{
		super.viewDidAppear(animated)
		refreshTable()//to removeGradientLayer
		updateAllFoldersCounters()
	}

	override func viewWillDisappear(_ animated:Bool)
	{
		collapseSlidings()
		super.viewWillDisappear(animated)
	}

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
	{
		let cell = sender as! AcquDocCell
		let row = m_pDocsListViewTableAcquintance.indexPath(for:cell)?.row
		
		let pDocInfo = m_DocList[m_indexes[row!]]
		
		var frame = cell.imageMark.frame
		frame.origin.y = 0
		frame.size.width += 2*frame.size.width
		frame.size.height = cell.frame.size.height
		if frame.contains(cell.m_pt)
		{
			if pDocInfo.isSelected
			{
				pDocInfo.isSelected = false
				m_cSelected -= 1
				cell.imageMark.image = m_imgMarkedOff
			}
			else
			{
				pDocInfo.isSelected = true
				cell.imageMark.image = m_imgMarkedOn
				m_cSelected += 1
			}
			if m_cSelected > 0
			{
				refreshTable()
			}
			resizeDocsListTable()
			return false
		}
		return true
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let cell = sender as! AcquDocCell
		let row = m_pDocsListViewTableAcquintance.indexPath(for:cell)?.row

		cell.contentView.makeGradient(true,ClrDef.clrGrad1Blue.cgColor,ClrDef.clrGrad2Blue.cgColor)
		
		collapseSlidings()

		let pDocInfo = m_DocList[m_indexes[row!]]
		let pDocViewController = segue.destination as? DocViewController
		GlobDat.curDocId = pDocInfo.docId
		GlobDat.curTask = 0
		pDocViewController?.m_pCurDoc = pDocInfo
		pDocViewController?.m_pCurTask = pseudoTask
		pDocViewController?.prepareToShowAcqu()
	}

	func refreshTable()
	{
		m_pDocsListViewTableAcquintance.reloadData()
	}

	override func collapseSlidings()
	{
		if m_slidingFolders.getState() == SlidingView.State.stateExpanded
		{
			let originX = -(self.view.frame.size.width-m_slidingFolders.getTouchWidth())
			m_slidingFolders.setState(SlidingView.State.stateCollapsed)
			animateSlidingFolders(originX,0.7)
			updateFoldersTouchAreaBackgroundColor()
		}
	}

	func animateSlidingFolders(_ originX:CGFloat,_ duration:TimeInterval)
	{
		UIView.animate(withDuration:duration,animations:
			{[unowned self] in
				self.m_slidingFolders.setOriginX(originX)
		})
	}

	func updateFoldersTableWidthAndOrigin()
	{
		let gap:CGFloat = 10
		let deltaWidth = m_slidingFolders.getTouchWidth()+gap
		var width = m_slidingFolders.m_View.frame.size.width-deltaWidth
		var newOriginX = gap
		if m_slidingFolders.getState() == SlidingView.State.stateExpanded
		{
			width -= deltaWidth
			newOriginX = deltaWidth
		}
		m_pFoldersTable.setWidth(width)
		m_pFoldersTable.setXOrigin(newOriginX)
		m_pAcquaintanceFolders.refreshFolders()
	}

	func dateDeliverAcquaintance(_ pDoc1:DocMO,_ pDoc2:DocMO) -> Bool
	{
		return pDoc2.acquaintanceDeliverDate > pDoc1.acquaintanceDeliverDate
	}

	func loadAllDocumentsList()
	{
		m_DocList.removeAll()
		m_indexes.removeAll()

		let foldersId = m_pAcquaintanceFolders.getFolderIdsArray()
		for folderId in foldersId
		{
			let req:NSFetchRequest<DocMO> = DocMO.fetchRequest()
			req.predicate = NSPredicate(format:"visible==YES AND SUBQUERY(foldersList, $x, $x.folderId == %d).@count > 0",folderId)
			if let arDocs = try? m_moc!.fetch(req)
			{
				for pDoc in arDocs
				{
					if m_DocList.index(where:{$0.docId == pDoc.docId}) == nil
					{
						m_DocList.append(pDoc)
					}
				}
			}
		}
		m_DocList.sort(by:dateDeliverAcquaintance)
	}

	func updateAllFoldersCounters()
	{
		for pFolderInfo in m_pAcquaintanceFolders.m_arFolders
		{
			pFolderInfo.docsUnread = 0
			pFolderInfo.docsAll = 0
			for pDoc in m_DocList
			{
				var bCanAdd = false
				if pFolderInfo.folderId == AllDocsFolderId {bCanAdd = true}
				if !bCanAdd
				{
					if pDoc.foldersList?.index(where: {$0.folderId == pFolderInfo.folderId}) != nil
					{
						bCanAdd = true
					}
				}
				if bCanAdd
				{
					if pDoc.haveBeenRead < 2 {pFolderInfo.docsUnread += 1}
					pFolderInfo.docsAll += 1
				}
			}
			if pFolderInfo.folderId == AllDocsFolderId {m_counterAllUnread = pFolderInfo.docsUnread}
		}
		m_pAcquaintanceFolders.refreshFolders()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUnreadDocsCounter),object:m_counterAllUnread)
	}

	@objc func docFolderSelected(notification: NSNotification)
	{
		let pFolderInfo = notification.object as! FolderInfo
		
		m_AcquaintanceFolderId = pFolderInfo.folderId
		self.m_navTitle = pFolderInfo.folderName
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kNavigationTitleChanged),object:nil)
		if m_DocList.count == 0 {loadAllDocumentsList()}
		loadFolderDocumentsList()
		refreshTable()
		collapseSlidings()
		Utils.prefsSet(m_AcquaintanceFolderId,Utils.createUniq_pressedAcquFolderIdKey())
	}

	@objc func resizeFolderSliding(notification: NSNotification)
	{
		var deltaH:CGFloat = 0
		var cRows = notification.object as! Int
		if cRows < 3 {cRows = 3}
		else if cRows > 7
		{
			cRows = 7
			deltaH = tableRowH/2
		}
		m_slidingFolders.updateSubviewsYOriginAndHeights(CGFloat(cRows)*tableRowH + deltaH)
		
		updateFoldersTouchAreaBackgroundColor()
		
		resizeDocsListTable()
	}

	@objc func processDocHaveBeenRead(notification: NSNotification)
	{//not realized now
	}

	func loadFolderDocumentsList()
	{
		let cItems = m_DocList.count
		m_indexes.removeAll()
		if m_AcquaintanceFolderId == NoFolderSelectedId {return}
		if m_AcquaintanceFolderId == AllDocsFolderId
		{
			for i in 0..<cItems {m_indexes.append(i)}
		}
		else
		{
			for i in 0..<cItems
			{
				let pDoc = m_DocList[i]
				if pDoc.foldersList?.index(where:{$0.folderId == m_AcquaintanceFolderId}) != nil
				{
					m_indexes.append(i)
				}
			}
		}
	}

	func resizeDocsListTable()
	{
		var newOriginY:CGFloat = 0
		if m_slidingFolders.getState() == SlidingView.State.stateLocked
		{
			newOriginY += m_slidingFolders.getHeight()
		}
		if originForProgress != newOriginY
		{
			originForProgress = newOriginY
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kProgressOriginShouldChange),object:originForProgress)//can send nil object
		}
		
		let viewH = self.view.frame.size.height
		UIView.animate(withDuration:0.7,animations:
		{[unowned self] in
			self.m_pDocsListViewTableAcquintance.setYOrigin(newOriginY)
			self.m_pDocsListViewTableAcquintance.setHeight(viewH-newOriginY)
		})
	}

	func updateFoldersTouchAreaBackgroundColor()
	{
		let bDrawAsSelected = ((m_slidingFolders.getState() == SlidingView.State.stateCollapsed) && !((m_AcquaintanceFolderId == AllDocsFolderId) || (m_AcquaintanceFolderId == NoFolderSelectedId)))
		m_slidingFolders.updateTouchAreaBackgroundColor(bDrawAsSelected)
	}

	override func updateData()
	{
		Utils.runOnUI
		{[unowned self] in
			self.createAcquintanceFoldersList()
			self.loadAllDocumentsList()
			self.updateAllFoldersCounters()
			self.restorePressedFolder()
		}
	}

	func createAcquintanceFoldersList()
	{
		m_pAcquaintanceFolders.createFoldersList()
		
		let ar = m_pAcquaintanceFolders.getFolderIdsArray()
		m_slidingFolders.m_View.isHidden = ar.count == 0
	}

	func restorePressedFolder()
	{
		let toRestoreFolderId = Utils.prefsGetInteger(Utils.createUniq_pressedAcquFolderIdKey())
		m_pAcquaintanceFolders.selectFolder(toRestoreFolderId)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			m_touchBeganPointGlobal = touch.location(in:self.view)
			m_bInsideSlidingFolders = m_slidingFolders.isTouchInside(touch)
			
			m_bMoveProcessed = false
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			let touchPoint = touch.location(in:self.view)
			let animationDuration:TimeInterval = 0.7
			var deltaX:CGFloat = 0
			if m_bInsideSlidingFolders
			{
				var idx = -1
				deltaX = touchPoint.x - m_touchBeganPointGlobal.x
				let origin0 = m_slidingFolders.getTouchWidth()
				let originsX =
				[
					-origin0,
					-(self.view.frame.size.width-origin0),
					0,
					-(self.view.frame.size.width-origin0)
				]
				let states = [SlidingView.State.stateExpanded,SlidingView.State.stateCollapsed,SlidingView.State.stateLocked,SlidingView.State.stateCollapsed]
				let state = m_slidingFolders.getState()
				if state == SlidingView.State.stateCollapsed
				{
					if deltaX > 50 {idx = 0}
				}
				else if state == SlidingView.State.stateExpanded
				{
					if deltaX < -50 {idx = 1}
					else if deltaX > 20 {idx = 2}
				}
				else if state == SlidingView.State.stateLocked
				{
					if deltaX < -50 {idx = 3}
				}
				
				if idx != -1
				{
					m_bInsideSlidingFolders = false
					
					m_slidingFolders.setState(states[idx])
					animateSlidingFolders(originsX[idx],animationDuration)
					resizeDocsListTable()

					updateFoldersTableWidthAndOrigin()
					updateFoldersTouchAreaBackgroundColor()
					
					m_bMoveProcessed = true
				}
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if !m_bMoveProcessed
		{
			var originX:CGFloat = 0
			let animationDuration:TimeInterval = 0.7
			
			if m_bInsideSlidingFolders
			{
				var bMove = false
				if m_slidingFolders.getState() == SlidingView.State.stateCollapsed
				{
					bMove = true
					originX = -m_slidingFolders.getTouchWidth()
					m_slidingFolders.setState(SlidingView.State.stateExpanded)
				}
				if m_slidingFolders.getState() == SlidingView.State.stateLocked
				{
					bMove = true
					originX = -(self.view.frame.size.width-m_slidingFolders.getTouchWidth())
					m_slidingFolders.setState(SlidingView.State.stateCollapsed)
				}
				
				if bMove
				{
					m_bInsideSlidingFolders = false
					
					animateSlidingFolders(originX,animationDuration)
					resizeDocsListTable()
					
					updateFoldersTableWidthAndOrigin()
					updateFoldersTouchAreaBackgroundColor()
				}
			}
		}
		m_bInsideSlidingFolders = false
	}

	override func getProgressOrigin() -> CGFloat
	{
		return originForProgress
	}

	override func getNavigationTitle() -> String
	{
		return m_navTitle
	}
}

extension AcquListViewController : UITableViewDataSource
{
	func tableView(_ tableView: UITableView,numberOfRowsInSection: Int) -> Int
	{
		return m_indexes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier:"ALC") as! AcquDocCell
		cell.contentView.removeGradientLayer()

		let row = cellForRowAt.row
		let docInfo = m_DocList[m_indexes[row]]

		cell.imageMark.image = docInfo.isSelected ? m_imgMarkedOn : m_imgMarkedOff
		cell.imageBadge.isHidden = docInfo.haveBeenRead > 1

		let bShowStamp = true//docInfo.controlStateCode != 0 
		if bShowStamp
		{
			//cell.stampDate.text = MyDF.dfDateOnly.string(from:docInfo.controlDate!)
			cell.stampDate.text = "1.07.2016"//test - remove
		}
		cell.superForStamp.isHidden = !bShowStamp
		cell.constraint1To2.isActive = bShowStamp
		cell.constraint2To3.isActive = bShowStamp

		cell.imagePriority.isHidden = !docInfo.priority
		cell.constraint1To3.isActive = docInfo.priority
		cell.constraint2To3.isActive = docInfo.priority		

		cell.docHeader.text = docInfo.documentInfo

		let dt1 = docInfo.acquaintanceDeliverDate
		cell.docDateDeliver.text = String(format:"DateDeliver".localized,MyDF.dfShortShort.string(from:dt1))

		cell.docTitle.text = docInfo.docTitle

		return cell
	}
}
