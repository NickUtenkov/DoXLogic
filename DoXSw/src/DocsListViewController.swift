//
//  DocsListViewController.swift
//  DoXSw
//
//  Created by Nick Utenkov on 04/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class DocsListViewController : MyVC
{
	struct ClassifierButtonsInfo
	{
		var imageName = "",title = ""
		var eClass:Int = 0,folderId:Int = 0,nOrder:Int = 0
	}
	
	@IBOutlet weak var tableToProcess:UITableView!//color EFF5F8
	@IBOutlet weak var tableProcessed:UITableView!
	@IBOutlet var m_slidingFolders:SlidingView!//crash if weak
	@IBOutlet var m_slidingDates:SlidingView!//crash if weak
	@IBOutlet weak var m_viewDate0:DateButton!
	@IBOutlet weak var m_viewDate1:DateButton!
	@IBOutlet weak var m_viewDate2:DateButton!
	@IBOutlet weak var m_viewDate3:DateButton!
	@IBOutlet weak var m_viewDate4:DateButton!
	@IBOutlet weak var m_viewDate5:DateButton!
	@IBOutlet weak var m_viewDate6:DateButton!
	@IBOutlet weak var m_viewDate7:DateButton!
	@IBOutlet weak var m_viewDate8:DateButton!
	@IBOutlet weak var m_SignProcessedSuper:UIView!
	@IBOutlet weak var m_SignProcessedLabel:UILabel!
	@IBOutlet weak var m_SignUnprocessedSuper:UIView!
	@IBOutlet weak var m_SignUnprocessedLabel:UILabel!

	private var m_currentList = 0

	private var m_groupInfo:[DateButton] = []

	private var m_currentEClass = 0,m_currentFolderId = 0
	private var m_DocList:[DocMO] = []
	private var m_cUnprocessed = 0,m_cProcessed = 0
	fileprivate var m_indexes:Dictionary<Int,[DocMO]> = [0:[],1:[]]

	private var m_navItemTitle = ""
	private var m_navTitle = ""

	private var m_touchBeganPointGlobal = CGPoint.zero
	private var m_bMoveProcessed:Bool = false

	private var m_arButtons:[ClassifierButton] = []//using this to not depend on subviews of m_slidingFolders.m_contentView
	private var m_columns:Int = 0
	private var m_originalSlidingFoldersH:CGFloat = 0.0

	private var pressedClassifierButton:ClassifierButton?

	private enum Inside:Int
	{
		case insideNone = 0,insideFolders,insideDates,insideProcessed,insideUnprocessed
	}
	private var insideArea:Inside = .insideNone

	private static let CountStdButtons = 6
	private var originForProgress:CGFloat = 0.0
	
	var m_moc:NSManagedObjectContext?

	private let FontTitle = "Arial"
	fileprivate let FontHeader = "Arial-Bold"
	private let SizeTitle:CGFloat = 16.0
	private let SizeHeader:CGFloat = 16
	fileprivate let SizeAction:CGFloat = 20
	fileprivate var fntTitle:UIFont!

	fileprivate let Gap1:CGFloat = 4
	fileprivate let Gap2:CGFloat = 3
	fileprivate let Gap3:CGFloat = 8
	private let Gap4:CGFloat = 9
	fileprivate let GapImages:CGFloat = 5
	fileprivate let cyHeader:CGFloat = 20
	private let NumRowsTitle = 3
	private let cyTitleLine:CGFloat = 20
	private var cyMaxTitle:CGFloat = 0
	fileprivate let labelRoundRadius:CGFloat = 4.0

	private let ViewSizeX:CGFloat = 110
	private let MinBtnGap:CGFloat = 5
	private let ViewOffset:CGFloat = 6
	private var LabelNameW:CGFloat = 0
	private let FontSizeName:CGFloat = 12
	private var LabelNumberH:CGFloat = 0
	private var LabelNameH:CGFloat = 0
	private let SlidingGap:CGFloat = 2
	private let ClassifImageH:CGFloat = 50
	private var ctx1 = 0
	private var ourWidth:CGFloat = 0
	lazy var dummyTask:TaskInfo =
	{
		let m_pDummyTaskInfo = TaskInfo(nil)
		m_pDummyTaskInfo.displayEClassId = GlobDat.eClass_AcceptExecution
		return m_pDummyTaskInfo
	}()

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		if UserDefaults.standard.object(forKey:Utils.createUniq_pressedEClassIdKey()) == nil
		{
			Utils.prefsSet(0,Utils.createUniq_pressedEClassIdKey())
			Utils.prefsSet(0,Utils.createUniq_pressedFolderIdKey())
		}
		m_currentEClass = Utils.prefsGetInteger(Utils.createUniq_pressedEClassIdKey())
		m_currentFolderId = Utils.prefsGetInteger(Utils.createUniq_pressedFolderIdKey())
		
	
		m_navTitle = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as! String
		
		cyMaxTitle = CGFloat(NumRowsTitle)*cyTitleLine
		
		LabelNameW = ViewSizeX
		LabelNumberH = (FontSizeName+2)//4
		LabelNameH = (FontSizeName)*3
		fntTitle = UIFont(name:FontTitle, size:SizeTitle)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if context == &ctx1
		{
			if ourWidth != self.view.frame.size.width
			{
				ourWidth = self.view.frame.size.width
				tableToProcess.setXOrigin((m_currentList==0) ? 0 : -ourWidth)
				tableProcessed.setXOrigin((m_currentList==1) ? 0 : ourWidth)
				self.tableToProcess.reloadData()
				self.tableProcessed.reloadData()
				resizeTables()
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

		//tableToProcess.separatorColor = UIColor.clear
		tableToProcess.rowHeight = UITableViewAutomaticDimension
		tableToProcess.estimatedRowHeight = 40

		tableProcessed.separatorColor = UIColor.clear
		tableProcessed.rowHeight = UITableViewAutomaticDimension
		tableProcessed.estimatedRowHeight = 40
		
		m_groupInfo.append(m_viewDate0)
		m_groupInfo.append(m_viewDate1)
		m_groupInfo.append(m_viewDate2)
		m_groupInfo.append(m_viewDate3)
		m_groupInfo.append(m_viewDate4)
		m_groupInfo.append(m_viewDate5)
		m_groupInfo.append(m_viewDate6)
		m_groupInfo.append(m_viewDate7)
		m_groupInfo.append(m_viewDate8)
		initFilterDates()

		m_slidingFolders.didLoad()
		m_slidingFolders.m_LabelNames = ["Folders".localized,"Lock".localized,"Unlock".localized,""]
		m_slidingFolders.m_LabelSigns = ["\u{2162}","\u{2192}","\u{2190}",""]
		m_slidingFolders.m_BackImage = UIImage(named:"slider_folders_selected.png")
		m_slidingFolders.funcContentWidthChanged = {[unowned self] in self.updateClassifierButtonsSizeAndOrigin()}
		m_slidingFolders.funcHeightChanged = {[unowned self] in self.updateFoldersTouchAreaBackgroundColor()}
		
		m_slidingFolders.m_stateLockedPrefsKey = Utils.createUniq_FoldersLockedKey()
		let bFoldersLocked = Utils.prefsGetBool(m_slidingFolders.m_stateLockedPrefsKey)
		if !bFoldersLocked {m_slidingFolders.setInitialOriginX(self.view.frame.size.width)}
		else
		{
			m_slidingFolders.setState(.stateLocked)
			animateSlidingFolders(0,0.5)
		}

		m_slidingDates.didLoad()
		m_slidingDates.m_LabelNames = ["Dates".localized,"Lock".localized,"Unlock".localized,""]
		m_slidingDates.m_LabelSigns = ["\u{2162}","\u{2192}","\u{2190}",""]
		m_slidingDates.m_BackImage = UIImage(named:"slider_dates_selected.png")
		m_slidingDates.funcContentWidthChanged = {[unowned self] in self.updateDatesSizeAndOrigin()}

		m_slidingDates.m_stateLockedPrefsKey = Utils.createUniq_DatesLockedKey()
		let bDatesLocked = Utils.prefsGetBool(m_slidingDates.m_stateLockedPrefsKey)
		if !bDatesLocked {m_slidingDates.setInitialOriginX(self.view.frame.size.width)}
		else
		{
			m_slidingDates.setState(.stateLocked)
			animateSlidingDates(0,0.5)
		}
		
		swapSlidings()
		resizeTables()

		updateDatesButtonsBackground()

		m_originalSlidingFoldersH = m_slidingFolders.getHeight()

		m_SignProcessedLabel.roundCorners(SlidingView.cornerRadius,[.topRight , .topLeft])
		setSignProcessedText(0)
		m_SignProcessedSuper.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2*3))

		m_SignUnprocessedLabel.roundCorners(SlidingView.cornerRadius,[.bottomRight , .bottomLeft])
		setSignUnprocessedText(0)
		m_SignUnprocessedSuper.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2*3))

		let viewW = self.view.frame.size.width
		tableProcessed.setXOrigin(0+viewW)
		m_SignUnprocessedSuper.setXOrigin(viewW+m_SignUnprocessedSuper.frame.size.width)

		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.processNotificationClassifierButtonPressed), name:NSNotification.Name(rawValue:ClassifierButton.kClassifierButtonPressed), object:nil)
		nc.addObserver(self, selector:#selector(self.processNotificationDateButtonPressed), name:NSNotification.Name(rawValue:DateButton.kDateButtonPressed), object:nil)
		nc.addObserver(self, selector:#selector(self.createClassifierButtonsInNotification), name:NSNotification.Name(rawValue:GlobDat.kPresentationsDownloaded), object:nil)
		nc.addObserver(self, selector:#selector(self.processReadConfirmed), name:NSNotification.Name(rawValue:GlobDat.kTaskReadConfirmed), object:nil)

		self.view.addObserver(self, forKeyPath:"frame", options: .new, context:&ctx1)
	}

	override func viewWillAppear(_ animated:Bool)
	{
		super.viewWillAppear(animated)
		updateDateLabelsCounts()
	}

	override func viewWillDisappear(_ animated:Bool)
	{
		collapseSlidings()
		super.viewWillDisappear(animated)
	}
	
	override func viewDidAppear(_ animated:Bool)
	{
		super.viewDidAppear(animated)
		tableToProcess.reloadData()//to removeGradientLayer
		tableProcessed.reloadData()//to removeGradientLayer
		updateDatesTouchAreaBackgroundColor()
	}

	func initFilterDates()
	{
		var curDate = Date()
		var curSeconds = curDate.timeIntervalSinceReferenceDate
		curSeconds -= Double(Int(curSeconds) % 86400)
		curDate = Date(timeIntervalSinceReferenceDate:curSeconds)

		m_groupInfo[0].bUsing = true
		m_groupInfo[0].minDate = Date.distantPast
		m_groupInfo[0].maxDate = Date.distantFuture
		
		m_groupInfo[1].minDate = Date.distantPast
		m_groupInfo[1].maxDate = curDate
		
		m_groupInfo[2].minDate = curDate
		m_groupInfo[2].maxDate = curDate + 86400
		
		m_groupInfo[3].minDate = m_groupInfo[2].maxDate
		m_groupInfo[3].maxDate = m_groupInfo[2].maxDate + 86400

		let gregorian = NSCalendar(identifier:.gregorian)
		let dayOfWeek = gregorian!.ordinality(of:.day,in:.weekday,for:curDate)
		var offsetComponents = DateComponents()
		offsetComponents.setValue(-dayOfWeek,for:.day)
		m_groupInfo[4].minDate = gregorian!.date(byAdding:offsetComponents, to:curDate, options: [])!
		m_groupInfo[4].maxDate = m_groupInfo[4].minDate + 86400*7
		
		m_groupInfo[5].minDate = m_groupInfo[4].maxDate
		m_groupInfo[5].maxDate = m_groupInfo[5].minDate + 86400*7

		let daysRangeCurMonth = gregorian!.range(of:.day, in:.month, for:curDate)
		let daysInMonth:Int = daysRangeCurMonth.length
		let dayOfMonth = gregorian!.ordinality(of:.day,in:.weekday,for:curDate) - 1
		offsetComponents = DateComponents()
		offsetComponents.setValue(-dayOfMonth,for:.day)
		m_groupInfo[6].minDate = gregorian!.date(byAdding:offsetComponents, to:curDate, options: [])!
		m_groupInfo[6].maxDate = m_groupInfo[6].minDate + TimeInterval(Int(86400*daysInMonth))

		let anyDateInNextMonth = m_groupInfo[6].maxDate + 1
		let daysRangeNextMonth = gregorian!.range(of:.day, in:.month, for:anyDateInNextMonth)
		let daysInNextMonth = daysRangeNextMonth.length
		m_groupInfo[7].minDate = m_groupInfo[6].maxDate
		m_groupInfo[7].maxDate = m_groupInfo[7].minDate + TimeInterval(Int(86400*daysInNextMonth))
		
		m_groupInfo[8].minDate = m_groupInfo[7].maxDate
		m_groupInfo[8].maxDate = Date.distantFuture
	}

	func loadAllDocumentsList()
	{
		
		let req:NSFetchRequest<DocMO> = DocMO.fetchRequest()
		req.predicate = NSPredicate(format:"visible==YES AND ANY tasks != nil")
		if let arDocs = try? m_moc!.fetch(req)//todo crash sometimes
		{
			m_DocList = arDocs
		}
		countDocuments(&m_cUnprocessed,&m_cProcessed)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kUnprocessedDocsCounter),object:m_cUnprocessed)
	}

	func findUnprocessedTaskOfEClass(_ arTasks:[TaskUnprocessed],_ eclassId:Int) -> TaskUnprocessed?
	{
		if let idx = arTasks.index(where:{($0.taskProcessed == nil) && ($0.displayEClassId == eclassId)})
		{
			return arTasks[idx]
		}
		return nil
	}
	
	func findProcessedTaskOfEClass(_ arTasks:[TaskUnprocessed],_ eclassId:Int) -> TaskUnprocessed?
	{
		if let idx = arTasks.index(where:{($0.taskProcessed != nil) && ($0.displayEClassId == eclassId)})
		{
			return arTasks[idx]
		}
		return nil
	}

	func taskListCountUnprocessed(_ arTasks:[TaskUnprocessed]) -> Int
	{
		return arTasks.filter({$0.taskProcessed == nil}).count
	}
	
	func taskListCountProcessed(_ arTasks:[TaskUnprocessed]) -> Int
	{
		return arTasks.filter({$0.taskProcessed != nil}).count
	}

	func calculateAllDocsCounters()
	{
		for i in 0..<9 {m_groupInfo[i].count = 0}
		for pDoc in m_DocList
		{
			let arTasks = Array(pDoc.tasks!)
			if let pTask = tasksFindLowestDateDeliver(arTasks)
			{
				for j in 0..<9
				{
					if (pTask.datePlanEnd! >= m_groupInfo[j].minDate) && (pTask.datePlanEnd! <= m_groupInfo[j].maxDate)
					{
						m_groupInfo[j].count += 1
					}
				}
			}
		}
	}

	func tasksFindLowestDateDeliver(_ arTasks:[TaskUnprocessed]) -> TaskUnprocessed?
	{
		var pTaksOut:TaskUnprocessed? = nil
		for pTask in arTasks
		{
			if pTask.taskProcessed == nil//need for calculateAllDocsCounters
			{
				if pTaksOut == nil {pTaksOut = pTask}
				else
				{
					if let dateDeliver1 = pTask.dateDeliver, let dateDeliverOut = pTaksOut!.dateDeliver
					{
						if dateDeliverOut > dateDeliver1
						{
							pTaksOut = pTask//get earlier task
						}
					}
				}
			}
		}
		return pTaksOut
	}

	func calcDatesCounts(_ pDoc:DocMO,_ eClassId:Int,_ folderId:Int)
	{
		var arCount = Array(repeating: Int(0),count: 9 )
		for pTI in pDoc.tasks!
		{
			if pTI.taskProcessed == nil
			{
				var bCanCheckTask = false
				if (eClassId == 0) && (folderId == 0) {bCanCheckTask = true}//AllDocuments
				else if (eClassId != 0) && (pTI.displayEClassId == eClassId) {bCanCheckTask = true}
				else if (eClassId == 0) && (pDoc.foldersList!.index(where:{$0.folderId==folderId}) != nil) {bCanCheckTask = true}

				if bCanCheckTask
				{
					for j in 0..<9
					{
						if (pTI.datePlanEnd! >= m_groupInfo[j].minDate) && (pTI.datePlanEnd! <= m_groupInfo[j].maxDate)
						{
							arCount[j] += 1
						}
					}
				}
			}
		}
		for j in 0..<9
		{
			if arCount[j] > 0 {m_groupInfo[j].count += 1}
		}
	}

	func comparePresentationDocOrder(_ pDoc1:DocMO,_ pDoc2:DocMO) -> Bool
	{
		var nOrder1 = 0,nOrder2 = 0
		for pDF in pDoc1.foldersList!
		{
			if pDF.folderId == m_currentFolderId
			{
				nOrder1 = pDF.nOrder
				break
			}
			for pDF in pDoc2.foldersList!
			{
				if pDF.folderId == m_currentFolderId
				{
					nOrder2 = pDF.nOrder
					break
				}
			}
		}
		return nOrder1 < nOrder2
	}

	func dateDeliverCompareUnprocessed(_ pDoc1:DocMO,_ pDoc2:DocMO) -> Bool
	{
		let bHaveAdrOrCor1 = (pDoc1.addresse != nil) || (pDoc1.correspondent != nil)
		let bHaveAdrOrCor2 = (pDoc2.addresse != nil) || (pDoc2.correspondent != nil)
		if bHaveAdrOrCor1 && !bHaveAdrOrCor2 {return true}
		if !bHaveAdrOrCor1 && bHaveAdrOrCor2 {return false}

		let pTask1 = pDoc1.tasksUnprocessed[0]
		let pTask2 = pDoc2.tasksUnprocessed[0]

		if (pTask1.dateDeliver == nil) && (pTask2.dateDeliver == nil) {return true}
		if (pTask1.dateDeliver != nil) && (pTask2.dateDeliver == nil) {return false}
		if (pTask1.dateDeliver == nil) && (pTask2.dateDeliver != nil) {return false}
		//both dates are not nil

		return pTask2.dateDeliver! > pTask1.dateDeliver!
	}
	
	func dateDeliverCompareProcessed(_ pDoc1:DocMO,_ pDoc2:DocMO) -> Bool
	{
		let bHaveAdrOrCor1 = (pDoc1.addresse != nil) || (pDoc1.correspondent != nil)
		let bHaveAdrOrCor2 = (pDoc2.addresse != nil) || (pDoc2.correspondent != nil)
		if bHaveAdrOrCor1 && !bHaveAdrOrCor2 {return false}
		if !bHaveAdrOrCor1 && bHaveAdrOrCor2 {return true}
		
		let pTask1 = pDoc1.tasksProcessed[0]
		let pTask2 = pDoc2.tasksProcessed[0]
		
		if (pTask1.dateDeliver == nil) && (pTask2.dateDeliver == nil) {return true}
		if (pTask1.dateDeliver != nil) && (pTask2.dateDeliver == nil) {return false}
		if (pTask1.dateDeliver == nil) && (pTask2.dateDeliver != nil) {return false}
		//both dates are not nil
		
		return pTask2.dateDeliver! > pTask1.dateDeliver!
	}

	func loadDocumentsListsByEClassOrFolderId()
	{
		for i in 0..<9 {m_groupInfo[i].count = 0}
		var indexes0:[DocMO] = []
		var indexes1:[DocMO] = []
		for pDoc in m_DocList
		{
			findUnprocessedDocTasks(pDoc,m_currentEClass,m_currentFolderId)
			findProcessedDocTasks(pDoc,m_currentEClass,m_currentFolderId)

			calcDatesCounts(pDoc,m_currentEClass,m_currentFolderId)
			if pDoc.tasksUnprocessed.count > 0 {indexes0.append(pDoc)}
			if pDoc.tasksProcessed.count > 0 {indexes1.append(pDoc)}
		}
		
		if (m_currentEClass == 0) && (m_currentFolderId != 0)//Presentations folder
		{
			indexes0.sort(by:comparePresentationDocOrder)
			indexes1.sort(by:comparePresentationDocOrder)
		}
		else
		{
			indexes0.sort(by:dateDeliverCompareUnprocessed)
			indexes1.sort(by:dateDeliverCompareProcessed)
		}
		m_indexes[0] = indexes0
		m_indexes[1] = indexes1
	}

	func updateDateLabelsCounts()
	{
		for i in 0..<9
		{
			m_groupInfo[i].lblCount.text = String(format:"%d",m_groupInfo[i].count)
		}
	}

	func datePlanEndCompare(_ pT1:TaskUnprocessed,_ pT2:TaskUnprocessed) -> Bool
	{
		let date1ToCompare = (pT1.displayEClassId != GlobDat.eClass_AcceptExecution) ? pT1.datePlanEnd : Date.distantFuture
		let date2ToCompare = (pT2.displayEClassId != GlobDat.eClass_AcceptExecution) ? pT2.datePlanEnd : Date.distantFuture
		return date1ToCompare! < date2ToCompare!
	}

	func findUnprocessedDocTasks(_ pDoc:DocMO,_ eClassId:Int,_ folderId:Int)
	{
		pDoc.tasksUnprocessed.removeAll(keepingCapacity:true)
		//print("eClassId=\(eClassId),folderId=\(folderId),cTasks=\(pDoc.tasks!.count)")
		for pTask in pDoc.tasks!
		{
			if pTask.taskProcessed != nil {continue}
			var bCanAddTask = false
			if (eClassId == 0) && (folderId == 0) {bCanAddTask = true}//AllDocuments
			else if (eClassId != 0) && (pTask.displayEClassId == eClassId) {bCanAddTask = true}
			else if (eClassId == 0) && (pDoc.foldersList!.index(where:{$0.folderId == folderId}) != nil) {bCanAddTask = true}
			if bCanAddTask
			{
				for j in 0..<9
				{
					if m_groupInfo[j].bUsing && (pTask.datePlanEnd! >= m_groupInfo[j].minDate) && (pTask.datePlanEnd! <= m_groupInfo[j].maxDate)
					{
						pDoc.tasksUnprocessed.append(pTask)
						break
					}
				}
			}
		}
		pDoc.tasksUnprocessed.sort(by:datePlanEndCompare)
	}

	func findProcessedDocTasks(_ pDoc:DocMO,_ eClassId:Int,_ folderId:Int)
	{
		pDoc.tasksProcessed.removeAll(keepingCapacity:true)
		for pTask in pDoc.tasks!
		{
			if pTask.taskProcessed == nil {continue}
			var bCanAddTask = false
			if (eClassId == 0) && (folderId == 0) {bCanAddTask = true}//AllDocuments
			else if (eClassId != 0) && (pTask.displayEClassId == eClassId) {bCanAddTask = true}
			else if (eClassId == 0) && (pDoc.foldersList!.index(where:{$0.folderId == folderId}) != nil) {bCanAddTask = true}
			if bCanAddTask
			{
				pDoc.tasksProcessed.append(pTask)
			}
		}
	}

	func animateSlidingDates(_ originX:CGFloat,_ duration:TimeInterval)
	{
		UIView.animate(withDuration:duration,animations:
		{[unowned self] in
			self.m_slidingDates.setOriginX(originX)
			self.updateDatesSizeAndOrigin()
		})
	}
	
	func animateSlidingFolders(_ originX:CGFloat,_ duration:TimeInterval)
	{
		UIView.animate(withDuration:duration,animations:
			{[unowned self] in
				self.m_slidingFolders.setOriginX(originX)
				self.updateClassifierButtonsSizeAndOrigin()
		})
	}

	func updateDatesSizeAndOrigin()
	{
		var maxWidth = m_slidingDates.m_contentView.frame.size.width
		let state = m_slidingDates.getState()
		if state == SlidingView.State.stateExpanded {maxWidth -= m_slidingDates.getTouchWidth()}
		let viewWidth = maxWidth/9
		
		var originX:CGFloat = 0
		for i in 0..<9
		{
			if state == SlidingView.State.stateCollapsed {originX = 0}
			else if state == SlidingView.State.stateExpanded {originX = m_slidingDates.getTouchWidth() + CGFloat(i)*(viewWidth-1)-1}
			else if state == SlidingView.State.stateLocked {originX = CGFloat(i)*(viewWidth-1)-1}
			m_groupInfo[i].setWidth(viewWidth)
			m_groupInfo[i].setXOrigin(originX)
		}
	}

	func updateClassifierButtonsSizeAndOrigin()
	{
		let cButtons = m_arButtons.count
		if cButtons == 0 {return}
		
		var maxWidth = m_slidingFolders.m_contentView.frame.size.width
		if m_slidingFolders.getState() == SlidingView.State.stateExpanded {maxWidth -= m_slidingFolders.getTouchWidth()}
		
		m_columns = Int(maxWidth/(ViewSizeX+MinBtnGap))
		let btnGap = (maxWidth-CGFloat(m_columns)*ViewSizeX)/CGFloat(m_columns)
		
		updateClassifierButtonsOrigin(btnGap)
		
		var deltaH:CGFloat = 0
		var rows = cButtons/m_columns
		if cButtons%m_columns > 0 {rows += 1}
		
		if rows>2 {deltaH = 20}
		let cUseRows = (rows > 1) ? 2 : 1

		let slidingFoldersHeight = CGFloat(cUseRows) * m_originalSlidingFoldersH + deltaH
		
		UIView.animate(withDuration:0.7,animations:
		{[unowned self] in
			self.m_slidingFolders.updateSubviewsYOriginAndHeights(slidingFoldersHeight)
			self.swapSlidings()
			self.resizeTables()
			
			(self.m_slidingFolders.m_contentView as! UIScrollView).contentSize = CGSize(w:0,h:CGFloat(rows)*self.m_originalSlidingFoldersH)
		})
	}

	func resizeTables()
	{
		var newOriginY:CGFloat = 0
		var cLocked = 0
		if m_slidingFolders.getState() == SlidingView.State.stateLocked
		{
			newOriginY += m_slidingFolders.getHeight()
			cLocked += 1
		}
		if m_slidingDates.getState() == SlidingView.State.stateLocked
		{
			newOriginY += m_slidingDates.getHeight()
			cLocked += 1
		}
		if cLocked==2 {newOriginY += SlidingGap}
		if originForProgress != newOriginY
		{
			originForProgress = newOriginY
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kProgressOriginShouldChange),object:originForProgress)//can send nil object
		}
		
		let viewH = self.view.frame.size.height
		UIView.animate(withDuration:0.3,animations:
			{[unowned self] in
				self.tableToProcess.setYOrigin(newOriginY)
				self.tableToProcess.setHeight(viewH-newOriginY)
				self.tableProcessed.setYOrigin(newOriginY)
				self.tableProcessed.setHeight(viewH-newOriginY)
		})
	}

	func swapSlidings()
	{
		if (m_slidingFolders.getState() == SlidingView.State.stateLocked) || (m_slidingDates.getState() != SlidingView.State.stateLocked)
		{
			m_slidingFolders.setOriginY(0)
			m_slidingDates.setOriginY(0+m_slidingFolders.getHeight()+SlidingGap)
		}
		else
		{
			m_slidingDates.setOriginY(0)
			m_slidingFolders.setOriginY(0+m_slidingDates.getHeight()+SlidingGap)
		}
	}

	func updateDatesButtonsBackground()
	{
		for i in 0..<9
		{
			if m_groupInfo[i].bUsing
			{
				var img = UIImage(named:"DatesBack62x78.png")
				img = img!.scaleToSize(m_groupInfo[i].frame.size)
				m_groupInfo[i].backgroundColor = UIColor(patternImage:img!)
				m_groupInfo[i].lblCount.textColor = UIColor.white
				m_groupInfo[i].lblTitle.textColor = UIColor.white
			}
			else
			{
				//removeGradientLayer(m_groupInfo[i].dateButton)
				m_groupInfo[i].backgroundColor = UIColor.white
				m_groupInfo[i].lblCount.textColor = ClrDef.clrText1
				m_groupInfo[i].lblTitle.textColor = ClrDef.clrText1
			}
		}
	}
	
	func setSignProcessedText(_ val:Int)
	{
		var str = ""
		if val > 0 {str = String(format:"(%d) %@",val,"\u{2193}")}
		else {str = "\u{2193}"}
		m_SignProcessedLabel.text = String(format:"SwitchToProcessed".localized,str)
	}

	func setSignUnprocessedText(_ val:Int)
	{
		var str = ""
		if val > 0 {str = String(format:"(%d) %@",val,"\u{2191}")}
		else {str = "\u{2191}"}
		m_SignUnprocessedLabel.text = String(format:"SwitchToUnprocessed".localized,str)
	}

	@objc func processNotificationClassifierButtonPressed(notification: NSNotification)
	{
		processClassifierButtonPressed(notification.object as? ClassifierButton)
	}

	@objc func processNotificationDateButtonPressed(notification: NSNotification)
	{
		let dateButton = notification.object as! DateButton
		updateDatesButtonsState(dateButton.tag)
		updateDatesButtonsBackground()
		collapseIfExpanded_Dates()
		updateDatesTouchAreaBackgroundColor()
		loadDocumentsListsByEClassOrFolderId()
		updateTablesRowHeights()
		updateDateLabelsCounts()
	}

	func processClassifierButtonPressed(_ pBtn:ClassifierButton?)
	{
		let prevClsBtn = pressedClassifierButton
		pressedClassifierButton = pBtn
		if prevClsBtn != pressedClassifierButton
		{
			updateClassifierButtonsBackground()
			collapseIfExpanded_Folders()
			updateFoldersTouchAreaBackgroundColor()
			
			if pressedClassifierButton != nil
			{
				m_navTitle = pressedClassifierButton!.btnName

				m_currentEClass = pressedClassifierButton!.eClass
				m_currentFolderId = pressedClassifierButton!.folderId

				setSignUnprocessedText(pressedClassifierButton!.cUnprocessed)
				setSignProcessedText(pressedClassifierButton!.cProcessed)
			}
			else
			{
				m_navTitle = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as! String

				m_currentEClass = -100
				m_currentFolderId = -100
			}
			
			NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kNavigationTitleChanged),object:originForProgress)//can send nil object
			
			Utils.prefsSet(m_currentEClass,Utils.createUniq_pressedEClassIdKey())
			Utils.prefsSet(m_currentFolderId,Utils.createUniq_pressedFolderIdKey())
			
			if m_DocList.count == 0 {loadAllDocumentsList()}
		}
		
		if pressedClassifierButton != nil {loadDocumentsListsByEClassOrFolderId()}
		updateTablesRowHeights()
		updateDateLabelsCounts()
		
		restoreListOffset()
	}

	@objc func createClassifierButtonsInNotification(notification: NSNotification)
	{
		self.performSelector(onMainThread: #selector(self.createClassifierButtons), with: nil, waitUntilDone: false)
	}

	@objc func createClassifierButtons()
	{
		let bHideStd =
		[
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffSogl),
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffPodpis),
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffRassmotr),
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffExec) || GlobDat.bIsBoss,
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffAcceptExec),
			Utils.prefsGetBool(GlobDat.kKey_SwitchOffRead)
		]
		let order =
		[
			GlobDat.eClass_DocflowReferencesAgreeDocument,
			GlobDat.eClass_DocflowReferencesApproveDocument,
			GlobDat.eClass_DocflowReferencesReviewDocument,
			GlobDat.eClass_WorkflowReferencesFormalTask,
			GlobDat.eClass_AcceptExecution,
			GlobDat.eClass_DocflowTaskReadDocument
		]
		var arButtonsInfo:[ClassifierButtonsInfo] = []
		for i in 0..<DocsListViewController.CountStdButtons
		{
			if bHideStd[i] {continue}
			let idx = EClasses.getIndexByEClasId(order[i])
			if idx != -1
			{
				var pBtnInfo = ClassifierButtonsInfo()
				pBtnInfo.imageName = EClasses.getIconName(idx)
				pBtnInfo.title = EClasses.getButtonName(idx)
				pBtnInfo.eClass = order[i]
				pBtnInfo.folderId = 0
				arButtonsInfo.append(pBtnInfo)
			}
		}
		addFoldersToArray(&arButtonsInfo)
		
		var pBtnInfo = ClassifierButtonsInfo()
		pBtnInfo.imageName = "AllFolders.png"
		pBtnInfo.title = "ShowFolderContentsAll".localized
		pBtnInfo.eClass = 0
		pBtnInfo.folderId = 0
		arButtonsInfo.append(pBtnInfo)
		//end filling array

		/*var bAdded = false,bRemoved = false
		for pBtnInfo in arButtonsInfo
		{
			let idx = m_arButtons.index(where:{($0.eClass == pBtnInfo.eClass) && ($0.folderId == pBtnInfo.folderId) && ($0.btnName == pBtnInfo.title) && ($0.nOrder == pBtnInfo.nOrder)})
		}*/
		var arButtons:[ClassifierButton] = []
		for pBtnInfo in arButtonsInfo
		{
			let bAlignTop = (pBtnInfo.eClass == 0)
			let viewToAdd = createClassifierButton(UIImage(named:pBtnInfo.imageName)!,pBtnInfo.title,bAlignTop)
			viewToAdd.eClass = pBtnInfo.eClass
			viewToAdd.folderId = pBtnInfo.folderId
			viewToAdd.btnName = pBtnInfo.title
			viewToAdd.nOrder = pBtnInfo.nOrder
			arButtons.append(viewToAdd)
			viewToAdd.restoreScrollOffsets()
		}
		for viewToAdd in arButtons {m_slidingFolders.m_contentView.addSubview(viewToAdd)}
		
		let arGone = m_arButtons
		m_arButtons = arButtons
		
		for view in arGone {view.removeFromSuperview()}

		updateClassifierButtonsSizeAndOrigin()
		resizeTables()
		restorePressedClassifierButton()
		updateClassifierButtonsBackground()
		updateButtonsDocCounters()//call only after restorePressedClassifierButton
	}
	
	@objc func processReadConfirmed(notification: NSNotification)
	{
		updateData()
	}

	override func collapseSlidings()
	{
		collapseIfExpanded_Dates()
		collapseIfExpanded_Folders()
	}

	func collapseIfExpanded_Folders()
	{
		if m_slidingFolders.getState() == SlidingView.State.stateExpanded
		{
			let originX = -(self.view.frame.size.width-m_slidingFolders.getTouchWidth())
			m_slidingFolders.setState(SlidingView.State.stateCollapsed)
			animateSlidingFolders(originX,0.5)
			swapSlidings()
			resizeTables()
		}
	}

	func collapseIfExpanded_Dates()
	{
		if m_slidingDates.getState() == SlidingView.State.stateExpanded
		{
			let originX = -(self.view.frame.size.width-m_slidingDates.getTouchWidth())
			m_slidingDates.setState(SlidingView.State.stateCollapsed)
			animateSlidingDates(originX,0.5)
		}
	}

	func updateFoldersTouchAreaBackgroundColor()
	{
		var bDrawAsSelected = true
		if m_slidingFolders.getState() != SlidingView.State.stateCollapsed {bDrawAsSelected = false}
		else
		{
			if m_arButtons.count > 0
			{
				if m_arButtons[m_arButtons.count-1] == pressedClassifierButton {bDrawAsSelected = false}
				else if pressedClassifierButton == nil {bDrawAsSelected = false}
			}
			else {bDrawAsSelected = false}
		}
		m_slidingFolders.updateTouchAreaBackgroundColor(bDrawAsSelected)
	}

	func updateDatesTouchAreaBackgroundColor()
	{
		m_slidingDates.updateTouchAreaBackgroundColor((m_slidingDates.getState() == SlidingView.State.stateCollapsed) && !m_groupInfo[0].bUsing)
	}

	func updateClassifierButtonsOrigin(_ btnGap:CGFloat)
	{
		var i = 0
		var newOriginX:CGFloat = 0,offsetX = btnGap/2,offsetY = (m_originalSlidingFoldersH-ViewSizeX)/2
		for pBtn in m_arButtons
		{
			if (i>0) && (i%m_columns==0)
			{
				offsetX = btnGap/2//reset offset
				offsetY += m_originalSlidingFoldersH
			}
			
			let state = m_slidingFolders.getState()
			if state == SlidingView.State.stateCollapsed {newOriginX = 0}
			else if state == SlidingView.State.stateExpanded {newOriginX = offsetX + m_slidingFolders.getTouchWidth()}
			else if state == SlidingView.State.stateLocked {newOriginX = offsetX}
			pBtn.setOrigin(newOriginX,offsetY)
			offsetX += pBtn.frame.size.width + btnGap
			i += 1
		}
	}

	func updateClassifierButtonsBackground()
	{
		var i = 0
		for pBtn in m_arButtons
		{
			if pBtn == pressedClassifierButton
			{
				pBtn.backgroundColor = UIColor(patternImage:UIImage(named:"ClassifButtonBack_selected.png")!)
				(pBtn.viewWithTag(1) as! UILabel).textColor = UIColor.white
				(pBtn.viewWithTag(2) as! UILabel).textColor = UIColor.white
			}
			else
			{
				let bStdButton = (pBtn.eClass != 0)
				pBtn.backgroundColor = UIColor(patternImage:UIImage(named:(bStdButton ? "ClassifButtonBack1.png" : "ClassifButtonBack2.png"))!)
				(pBtn.viewWithTag(1) as! UILabel).textColor = ClrDef.clrText1
				(pBtn.viewWithTag(2) as! UILabel).textColor = ClrDef.clrText1
			}
			i += 1
		}
	}

	func updateTablesRowHeights()
	{
		Utils.runOnUI
		{[unowned self] in
			self.tableToProcess.reloadData()
			self.tableProcessed.reloadData()
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		let cell = sender as! DocListCell
		var tableView:UITableView!
		let idx = m_currentList
		if idx == 0 {tableView = tableToProcess}
		else {tableView = tableProcessed}
		let row = tableView.indexPath(for:cell)?.row

		let pDoc = m_indexes[idx]![row!]
		collapseSlidings()
		
		cell.contentView.makeGradient(true,ClrDef.clrGrad1Blue.cgColor,ClrDef.clrGrad2Blue.cgColor)//will NOT be seen after reload Data
		
		let arTasks = (idx == 0) ? pDoc.tasksUnprocessed : pDoc.tasksProcessed
		let pTask = arTasks[0]
		
		//let cTasks = arTasks.count
		var cAcceptExecTasks = 0
		for pTsk in arTasks
		{
			if pTsk.displayEClassId == GlobDat.eClass_AcceptExecution {cAcceptExecTasks += 1}
		}
		
		GlobDat.curDocId = pDoc.docId
		GlobDat.curTask = pTask.taskId
		var pTaskInfo:TaskInfo!
		if pTask.displayEClassId == GlobDat.eClass_AcceptExecution
		{
			pTaskInfo = dummyTask
		}
		else
		{
			pTaskInfo = TaskInfo(pTask)
		}

		let pDocViewController = segue.destination as? DocViewController
		pDocViewController?.m_pCurDoc = pDoc
		pDocViewController?.m_pCurTask = pTaskInfo
		pDocViewController?.prepareToShow(m_currentList == 1)
	}

	func moveCurrentDocumentToProcessed()
	{
		loadAllDocumentsList()
		loadDocumentsListsByEClassOrFolderId()
		updateButtonsDocCounters()
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocMoved),object:nil)
	}

	func moveCurrentDocumentToNotProcessed()
	{
		DispatchQueue.global(qos: .background).async(execute:
		{[unowned self] in
			self.loadAllDocumentsList()
			self.loadDocumentsListsByEClassOrFolderId()
			Utils.runOnUI{self.updateButtonsDocCounters()}
		})
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kDocMoved),object:nil)
	}

	func updateButtonsDocCounters()
	{
		var cUnprocessed = 0,cProcessed = 0
		
		for pBtn in m_arButtons
		{
			if (pBtn.eClass == 0) && (pBtn.folderId == 0)//AllDocuments
			{
				cUnprocessed = m_cUnprocessed
				cProcessed = m_cProcessed
			}
			else if pBtn.eClass == 0//Presentations folder
			{
				numberOfDocumentsInFolder(pBtn.folderId,&cUnprocessed,&cProcessed)
				(pBtn.viewWithTag(3) as! UIImageView).image = UIImage(named:(cUnprocessed > 0 ? "FolderOpened.png" : "FolderClosed.png"))
			}
			else {numberOfDocumentsOfClass(pBtn.eClass,&cUnprocessed,&cProcessed)}
			pBtn.cUnprocessed = cUnprocessed
			pBtn.cProcessed = cProcessed
			(pBtn.viewWithTag(1) as! UILabel).text = String(format:"%d",cUnprocessed)
		}
		if pressedClassifierButton != nil
		{
			setSignUnprocessedText(pressedClassifierButton!.cUnprocessed)
			setSignProcessedText(pressedClassifierButton!.cProcessed)
		}
	}

	func createClassifierButton(_ image:UIImage,_ name:String,_ bTop:Bool) -> ClassifierButton
	{
		let outView = ClassifierButton(frame:CGRect(x:0,y:0,width:ViewSizeX,height:ViewSizeX))

		var originY:CGFloat = 4
		let imgView = UIImageView(frame:CGRect(x:(ViewSizeX-image.size.width)/2,y:originY+(ClassifImageH-image.size.height)/2,w:image.size.width,h:image.size.height))
		imgView.image = image
		imgView.tag = 3
		outView.addSubview(imgView)
		
		let fnt = UIFont(name:"Arial",size:FontSizeName)
		originY += ClassifImageH+1
		//replace with MSLabel
		let labelName = UILabel(frame:CGRect(x:(ViewSizeX-LabelNameW)/2,y:originY,width:LabelNameW,height:LabelNameH))
		//labelName.lineHeight = 10//MSLabel property
		//labelName.verticalAlignment = (bTop ? MSLabelVerticalAlignmentTop : MSLabelVerticalAlignmentMiddle)//MSLabel property
		labelName.lineBreakMode = .byWordWrapping
		labelName.tag = 2
		labelName.text = name
		labelName.textAlignment = .center
		labelName.textColor = ClrDef.clrText1
		labelName.backgroundColor = UIColor.clear
		labelName.font = fnt
		labelName.numberOfLines = 3
		//labelName.minimumFontSize = 5
		outView.addSubview(labelName)
		
		originY += LabelNameH
		originY += (ViewSizeX-originY-LabelNumberH)/2
		let labelNumber = UILabel(frame:CGRect(x:(ViewSizeX-LabelNameW)/2,y:originY,width:LabelNameW,height:LabelNumberH))
		labelNumber.tag = 1
		labelNumber.text = "0"
		labelNumber.textAlignment = .center
		labelNumber.textColor = ClrDef.clrText1
		labelNumber.backgroundColor = UIColor.clear
		labelNumber.font = fnt
		//labelNumber.baselineAdjustment = UIBaselineAdjustmentAlignCenters
		outView.addSubview(labelNumber)

		return outView
	}

	func updateDatesButtonsState(_ idx:Int)
	{
		if m_slidingDates.getState() == SlidingView.State.stateExpanded
		{
			for i in 0..<9 {m_groupInfo[i].bUsing = false}
			m_groupInfo[idx].bUsing = true
		}
		else if m_slidingDates.getState() == SlidingView.State.stateLocked
		{
			m_groupInfo[idx].bUsing = !m_groupInfo[idx].bUsing
			var cSelected = 0
			for i in 1..<9 {if m_groupInfo[i].bUsing {cSelected += 1}}
			if cSelected == 0 {m_groupInfo[0].bUsing = true}
			else
			{
				if idx == 0
				{
					if m_groupInfo[0].bUsing {for i in 1..<9 {m_groupInfo[i].bUsing = false}}
					else {m_groupInfo[0].bUsing = false}
				}
				else
				{
					if m_groupInfo[idx].bUsing {m_groupInfo[0].bUsing = false}
				}
			}
		}
	}

	func addFoldersToArray(_ arButtons:inout [ClassifierButtonsInfo])
	{
		let moc = CoreDataManager.sharedInstance.createWorkerContext() 
		let req:NSFetchRequest<FolderPresMO> = FolderPresMO.fetchRequest()
		req.sortDescriptors = [NSSortDescriptor(key:"nOrder",ascending:true),NSSortDescriptor(key:"folderName",ascending:true)]
		if let folderRecords:[FolderPresMO] = try? moc.fetch(req)
		{
			for pFolderRec in folderRecords
			{
				var pBtnInfo = ClassifierButtonsInfo()
				pBtnInfo.imageName = "FolderOpened.png"
				pBtnInfo.title = pFolderRec.folderName!
				pBtnInfo.eClass = 0
				pBtnInfo.folderId = pFolderRec.folderId
				pBtnInfo.nOrder = pFolderRec.nOrder
				arButtons.append(pBtnInfo)
			}
		}
	}

	func restorePressedClassifierButton()
	{
		var viewPressed:ClassifierButton? = nil
		if let idx = m_arButtons.index(where:{($0.eClass == m_currentEClass) && ($0.folderId == m_currentFolderId)})
		{
			viewPressed = m_arButtons[idx]
		}
		processClassifierButtonPressed(viewPressed)
	}

	func updateListForPressedClassifierButton()
	{
		if pressedClassifierButton != nil {loadDocumentsListsByEClassOrFolderId()}
		updateTablesRowHeights()
		updateDateLabelsCounts()
	}

	func restoreListOffset()
	{
		if pressedClassifierButton != nil
		{
			let pt = CGPoint(x:0,y:pressedClassifierButton!.getOffset(m_currentList))
			if m_currentList == 0 {tableToProcess.contentOffset = pt}
			else {tableProcessed.contentOffset = pt}
		}
	}

	func countDocuments(_ cUnprocessed:inout Int,_ cProcessed:inout Int)
	{
		var setForUnprocessed:Set<Int> = []
		var setForProcessed:Set<Int> = []
		cUnprocessed = 0
		cProcessed = 0
		let order =
			[
				GlobDat.eClass_DocflowReferencesAgreeDocument,
				GlobDat.eClass_DocflowReferencesApproveDocument,
				GlobDat.eClass_DocflowReferencesReviewDocument,
				GlobDat.eClass_WorkflowReferencesFormalTask,
				GlobDat.eClass_AcceptExecution,
				GlobDat.eClass_DocflowTaskReadDocument
		]
		for i in 0..<order.count
		{
			let idx = EClasses.getIndexByEClasId(order[i])
			if idx != -1
			{
				putDocumentsOfClass(order[i],&setForUnprocessed,&setForProcessed)
			}
		}
		cUnprocessed = setForUnprocessed.count
		cProcessed = setForProcessed.count
	}

	func putDocumentsOfClass(_ eclassId:Int,_ setForUnprocessed:inout Set<Int>,_ setForProcessed:inout Set<Int>)
	{
		for pDoc in m_DocList
		{
			let arTasks = Array(pDoc.tasks!)
			if findUnprocessedTaskOfEClass(arTasks,eclassId) != nil {setForUnprocessed.insert(pDoc.docId)}
			if findProcessedTaskOfEClass(arTasks,eclassId) != nil {setForProcessed.insert(pDoc.docId)}
		}
	}

	func numberOfDocumentsOfClass(_ eclassId:Int,_ cUnprocessed:inout Int,_ cProcessed:inout Int)
	{
		cUnprocessed = 0
		cProcessed = 0
		for pDoc in m_DocList
		{
			let arTasks = Array(pDoc.tasks!)
			if findUnprocessedTaskOfEClass(arTasks,eclassId) != nil {cUnprocessed += 1}
			if findProcessedTaskOfEClass(arTasks,eclassId) != nil {cProcessed += 1}
		}
	}

	func numberOfDocumentsInFolder(_ folderId:Int,_ cUnprocessed:inout Int,_ cProcessed:inout Int)
	{
		cUnprocessed = 0
		cProcessed = 0
		for pDoc in m_DocList
		{
			if pDoc.foldersList?.index(where:{$0.folderId == folderId}) != nil
			{
				let arTasks = Array(pDoc.tasks!)
				cUnprocessed += taskListCountUnprocessed(arTasks) > 0 ? 1 : 0
				cProcessed += taskListCountProcessed(arTasks) > 0 ? 1 : 0
			}
		}
	}

	override func updateData()
	{
		DispatchQueue.global(qos: .background).async(execute:
			{[unowned self] in
				self.loadAllDocumentsList()
				Utils.runOnUI
				{
					self.updateListForPressedClassifierButton()
					self.updateButtonsDocCounters()
					if self.pressedClassifierButton == nil
					{
						self.calculateAllDocsCounters()//m_groupInfo[0].count = [self countUnprocessedDocuments]
						self.updateDateLabelsCounts()
					}
				}
		})
	}

	func animateToProcessed()
	{
		let viewW = self.view.frame.size.width
		
		m_SignProcessedSuper.alpha = 0.0
		m_SignUnprocessedSuper.alpha = 1.0
		
		let vertLine = UIView(frame:CGRect(x:0,y:0,width:1,height:tableProcessed.frame.size.height))
		vertLine.backgroundColor = UIColor.gray
		tableProcessed.addSubview(vertLine)
		
		UIView.animate(withDuration:0.7,animations:
		{[unowned self] in
			self.tableToProcess.setXOrigin(0-viewW)
			self.m_SignProcessedSuper.setXOrigin(-self.m_SignProcessedSuper.frame.size.width)
			
			self.tableProcessed.setXOrigin(0)
			self.m_SignUnprocessedSuper.setXOrigin(0-SlidingView.cornerRadius)
		},
		completion:
		{(finished: Bool) in
			vertLine.removeFromSuperview()
		}
		)

		m_currentList = 1
		restoreListOffset()
	}

	func animateToUnprocessed()
	{
		let viewW = self.view.frame.size.width
		
		m_SignProcessedSuper.alpha = 1.0
		m_SignUnprocessedSuper.alpha = 0.0
		
		let vertLine = UIView(frame:CGRect(x:0,y:0,width:1,height:tableProcessed.frame.size.height))
		vertLine.backgroundColor = UIColor.gray
		tableProcessed.addSubview(vertLine)
		
		UIView.animate(withDuration:0.7,animations:
			{[unowned self] in
				self.tableToProcess.setXOrigin(0)
				self.m_SignProcessedSuper.setXOrigin(viewW-self.m_SignProcessedSuper.frame.size.width+SlidingView.cornerRadius)
				
				self.tableProcessed.setXOrigin(viewW)
				self.m_SignUnprocessedSuper.setXOrigin(viewW+self.m_SignUnprocessedSuper.frame.size.width)
			},
		               completion:
			{(finished: Bool) in
				vertLine.removeFromSuperview()
		}
		)
		
		m_currentList = 0
		restoreListOffset()
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			m_touchBeganPointGlobal = touch.location(in:self.view)

			insideArea = .insideNone
			if m_slidingFolders.isTouchInside(touch) {insideArea = .insideFolders}
			else if m_slidingDates.isTouchInside(touch) {insideArea = .insideDates}
			else if m_SignProcessedSuper.frame.contains(m_touchBeganPointGlobal) {insideArea = .insideProcessed}
			else if m_SignUnprocessedSuper.frame.contains(m_touchBeganPointGlobal) {insideArea = .insideUnprocessed}
			
			m_bMoveProcessed = false
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			let touchPoint = touch.location(in:self.view)
			let animationDuration:TimeInterval = 0.7
			var idx = -1
			let deltaX:CGFloat = touchPoint.x - m_touchBeganPointGlobal.x

			switch insideArea
			{
				case .insideFolders :
					let origin1 = -(self.view.frame.size.width-m_slidingFolders.getTouchWidth())
					let originsX = [-m_slidingFolders.getTouchWidth(),origin1,0,origin1]
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
						m_bMoveProcessed = true
						
						m_slidingFolders.setState(states[idx])
						animateSlidingFolders(originsX[idx],animationDuration)
						swapSlidings()
						resizeTables()
						
						updateFoldersTouchAreaBackgroundColor()
					}
					break
				case .insideDates:
					let touchWidth = m_slidingDates.getTouchWidth()
					let originsX =
					[-touchWidth,
						-(self.view.frame.size.width-touchWidth),
						0,
						-(self.view.frame.size.width-touchWidth)
					]
					let states = [SlidingView.State.stateExpanded,SlidingView.State.stateCollapsed,SlidingView.State.stateLocked,SlidingView.State.stateCollapsed]
					if m_slidingDates.getState() == SlidingView.State.stateCollapsed
					{
						if deltaX > 50 {idx = 0}
					}
					else if m_slidingDates.getState() == SlidingView.State.stateExpanded
					{
						if deltaX < -50 {idx = 1}
						else if deltaX > 20 {idx = 2}
					}
					else if m_slidingDates.getState() == SlidingView.State.stateLocked
					{
						if deltaX < -50 {idx = 3}
					}
					
					if idx != -1
					{
						m_bMoveProcessed = true
						
						m_slidingDates.setState(states[idx])
						animateSlidingDates(originsX[idx],animationDuration)
						swapSlidings()
						resizeTables()
						
						updateDatesButtonsBackground()
						updateDatesTouchAreaBackgroundColor()
					}
					break
				case .insideProcessed :
					if deltaX < -10
					{
						animateToProcessed()
						m_bMoveProcessed = true
					}
					break
				case .insideUnprocessed :
					if deltaX > -10
					{
						animateToUnprocessed()
						m_bMoveProcessed = true
					}
					break
				default :
					break
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if !m_bMoveProcessed
		{
			var originX:CGFloat = 0
			var bMove:Bool = false
			let animationDuration:TimeInterval = 0.7
			
			switch insideArea
			{
				case .insideFolders :
					if m_slidingFolders.getState() == SlidingView.State.stateCollapsed
					{
						bMove = true
						originX = -m_slidingFolders.getTouchWidth()
						m_slidingFolders.setState(SlidingView.State.stateExpanded)
					}
					else if m_slidingFolders.getState() == SlidingView.State.stateLocked
					{
						bMove = true
						originX = -(self.view.frame.size.width-m_slidingFolders.getTouchWidth())
						m_slidingFolders.setState(SlidingView.State.stateCollapsed)
					}
					
					if bMove
					{
						animateSlidingFolders(originX,animationDuration)
						swapSlidings()
						resizeTables()
						
						updateFoldersTouchAreaBackgroundColor()
					}
					break
				case .insideDates :
					if m_slidingDates.getState() == SlidingView.State.stateCollapsed
					{
						bMove = true
						originX = -m_slidingDates.getTouchWidth()
						m_slidingDates.setState(SlidingView.State.stateExpanded)
					}
					if m_slidingDates.getState() == SlidingView.State.stateLocked
					{
						bMove = true
						originX = -(self.view.frame.size.width-m_slidingDates.getTouchWidth())
						m_slidingDates.setState(SlidingView.State.stateCollapsed)
					}
					
					if bMove
					{
						animateSlidingDates(originX,animationDuration)
						swapSlidings()
						resizeTables()
						
						updateDatesTouchAreaBackgroundColor()
					}
					break
				case .insideProcessed :
					animateToProcessed()
					break
				case .insideUnprocessed :
					animateToUnprocessed()
					break
				default :
					break
			}
		}
		
		insideArea = .insideNone
	}

	func scrollViewDidScroll(_ scrollView:UIScrollView)
	{
		if pressedClassifierButton != nil
		{
			var idx = -1
			if scrollView == tableToProcess {idx = 0}
			else if scrollView == tableProcessed {idx = 1}
			if idx != -1
			{
				pressedClassifierButton!.setOffset(scrollView.contentOffset.y,0)
			}
		}
	}

	override func getProgressOrigin() -> CGFloat
	{
		return 0
	}

	override func getNavigationTitle() ->String
	{
		return m_navTitle
	}

}

extension DocsListViewController : UITableViewDataSource
{
	func tableView(_ tableView: UITableView,numberOfRowsInSection: Int) -> Int
	{
		let idx = (tableView == tableToProcess) ? 0 : 1
		return m_indexes[idx]!.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt: IndexPath) -> UITableViewCell
	{
		let cell = tableToProcess.dequeueReusableCell(withIdentifier:"DLC") as! DocListCell
		cell.contentView.removeGradientLayer()
		
		let row = cellForRowAt.row
		let idx = (tableView == tableToProcess) ? 0 : 1
		let docInfo = m_indexes[idx]![row]
		
		cell.docHeader.text = docInfo.documentInfo
		
		let bShowAdr = !Utils.strNilOrEmpty(docInfo.addressOrCorrespondent)
		if bShowAdr
		{
			cell.docAddressOrCor.text = docInfo.addressOrCorrespondent
		}
		cell.docAddressOrCor.isHidden = !bShowAdr
		
		let arTasks = (idx == 0) ? docInfo.tasksUnprocessed : docInfo.tasksProcessed
		let taskInfo = tasksFindLowestDateDeliver(arTasks)
		let bShowDeliver = (taskInfo != nil) && (taskInfo!.dateDeliver != nil)
		if bShowDeliver
		{
			cell.docDateDeliver.text = String(format:"DateDeliver".localized,MyDF.dfShortShort.string(from:taskInfo!.dateDeliver!))
		}
		cell.docDateDeliver.isHidden = !bShowDeliver
		
		cell.docTitle.text = docInfo.docTitle
		
		let bShowStamp = docInfo.controlStateCode != 0 
		if bShowStamp
		{
			cell.stampDate.text = MyDF.dfDateOnly.string(from:docInfo.controlDate!)
		}
		cell.superForStamp.isHidden = !bShowStamp
		cell.constraint1To2.isActive = bShowStamp
		cell.constraint2To3.isActive = bShowStamp
		
		cell.imagePriority.isHidden = !docInfo.priority
		cell.constraint1To3.isActive = docInfo.priority
		cell.constraint2To3.isActive = docInfo.priority

		//var bAprove = false
		var pStr:NSAttributedString
		var bAcceptExecTakeIntoAccount = false
		var idxCell = 0
		let strAttr:NSMutableAttributedString = .init()
		for pTsk in arTasks
		{
			var bAcceptExecution = false
			if idx == 1//processed tasks
			{
				pStr = .init()
				/*let executeType = pTsk.taskProcessed!.executeType
				if executeType == TaskProcessed.executeTypeAssignExecutor
				{
					labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
					labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
				}
				else if executeType == TaskProcessed.executeTypeAcceptExecution//bAcceptExecution is true
				{
					bAcceptExecution = true
					if !bAcceptExecTakeIntoAccount
					{
						var cAccepted = 0,cNotAccepted = 0
						for pTask in docInfo.tasksProcessed
						{
							if pTask.displayEClassId == GlobDat.eClass_AcceptExecution
							{
								if pTask.taskProcessed!.result?.boolValue != nil {cAccepted += 1}
								else {cNotAccepted += 1}
							}
						}
						pStr = String(format:"strAcceptExecCounts".localized,cAccepted,cNotAccepted)
						if (cAccepted != 0) && (cNotAccepted == 0)
						{
							labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
							labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
						}
						else if (cNotAccepted != 0) && (cAccepted == 0)
						{
							labelActionColor = UIColor(red:1.00,green:0.38,blue:0.44,alpha:1.0)
							labelActionBackColor = UIColor(red:0.95,green:0.90,blue:0.91,alpha:1.0)
						}
						else
						{
							labelActionColor = UIColor(red:0.89,green:0.74,blue:0.23,alpha:1.0)
							labelActionBackColor = UIColor(red:0.92,green:0.94,blue:0.87,alpha:1.0)
						}
					}
				}
				else if (executeType == TaskProcessed.executeTypeResolution) || ((executeType & TaskProcessed.executeTypeConsidered) != 0)//check resolutions first (opUID will be in kTableName_ExecTask also)
				{
					if pTsk.displayEClassId == GlobDat.eClass_DocflowReferencesReviewDocument {pStr = "Considered".localized}//as before boss mode was added
					else {pStr = "strExecuted".localized}
					labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
					labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
				}
				else if ((executeType & TaskProcessed.executeTypeAgree) != 0) || ((executeType & TaskProcessed.executeTypeApprove) != 0)
				{
					bAprove = ((executeType & TaskProcessed.executeTypeResultOfTask) > 0)
					if pTsk.eclassId == GlobDat.eClass_DocflowReferencesAgreeDocument
					{
						pStr = bAprove ? "Agreed".localized : "NotAgreed".localized
					}
					else if pTsk.eclassId == GlobDat.eClass_DocflowReferencesApproveDocument
					{
						pStr = bAprove ? "Approved".localized : "NotApproved".localized
					}
					else {pStr = "Considered".localized}//for resolutions report
					if bAprove
					{
						labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
						labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
					}
					else
					{
						labelActionColor = UIColor(red:0.84,green:0.31,blue:0.31,alpha:1.0)
						labelActionBackColor = UIColor(red:0.93,green:0.90,blue:0.91,alpha:1.0)
					}
				}
				else if executeType == TaskProcessed.executeTypeChildTaskIssued
				{
					pStr = "ChildTaskIssued".localized
					labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
					labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
				}
				else if executeType == TaskProcessed.executeTypeConfirmRead
				{
					pStr = "strConfirmReaded".localized
					labelActionColor = UIColor(red:0.47,green:0.62,blue:0.04,alpha:1.0)
					labelActionBackColor = UIColor(red:0.86,green:0.93,blue:0.84,alpha:1.0)
				}*/
			}
			else
			{
				bAcceptExecution = (pTsk.displayEClassId == GlobDat.eClass_AcceptExecution)
				var strDate = ""
				if (pTsk.datePlanEnd != nil) && Utils.prefsGetBool(GlobDat.kKey_ShowExecutionDate) && !bAcceptExecution
				{
					strDate = String(format:"DatePlanEnd".localized,MyDF.dfDateOnly.string(from:(pTsk.datePlanEnd!)))
				}
				if !pTsk.consolidated
				{
					let dict =
					[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 20.0)!,
					 NSAttributedStringKey.foregroundColor:UIColor(red:0.15,green:0.68,blue:0.93,alpha:1.0),
					]
					pStr = .init(string:String(format:"%@. %@",EClasses.getEClassButtonNameByEClasId(pTsk.displayEClassId),strDate),attributes:dict)
				}
				else
				{
					let dict =
					[NSAttributedStringKey.font:UIFont(name: "Arial-BoldMT", size: 20.0)!,
					 NSAttributedStringKey.foregroundColor:UIColor(red:0.33,green:0.33,blue:0.33,alpha:1.0),
					]
					pStr = .init(string:String(format:"%@. %@","strConsolidated".localized,strDate),attributes:dict)
				}
			}
			
			if (!bAcceptExecution || (bAcceptExecution && !bAcceptExecTakeIntoAccount))
			{
				if idxCell != 0
				{
					strAttr.append(NSAttributedString(string: "\n",attributes:[:]))
				}
				strAttr.append(pStr)
			}
			if bAcceptExecution {bAcceptExecTakeIntoAccount = true}
			idxCell += 1
		}
		cell.tasksLabel.attributedText = strAttr
		cell.tasksLabel.backgroundColor = UIColor(red:0.86,green:0.93,blue:0.97,alpha:1.0)
		cell.tasksLabel.borderColor = UIColor(red:0.86,green:0.93,blue:0.97,alpha:1.0)
		//cell.tasksLabel.exerciseAmbiguityInLayout()//constraints
		//cell.intrinsicContentSize;invalidateIntrinsicContentSize()
		
		//var level = 0
		//cell.dumpHierarchy(&level)
		return cell
	}
}
