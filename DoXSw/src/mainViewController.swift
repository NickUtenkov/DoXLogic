//
//  ViewController.swift
//  DoXSw
//
//  Created by nick on 16/12/16.
//  Copyright © 2016 Nick Utenkov. All rights reserved.
//

import UIKit

final class mainViewController: UIViewController
{
	@IBOutlet weak var m_superForMainButtons:UIView!
	@IBOutlet weak var m_superForLists:UIView!
	@IBOutlet weak var m_btnDocuments:UIView!
	@IBOutlet weak var m_btnAcquintance:UIView!
	@IBOutlet weak var m_logoImageView:UIImageView!
	private let m_refreshButton = UIButton(type:.custom)
	private let m_progressButton = UIButton(type:.custom)
	private let m_messagesButton = UIButton(type:.custom)
	private var btnsMain:[UIView?] = [nil,nil]
	private var m_bFirstTimeInit:Bool = false
	private let m_moc = CoreDataManager.sharedInstance.mainMoc
	private var m_pDocsListViewController:DocsListViewController!
	private var m_pAcquListViewController:AcquListViewController!
	private var pressedMainBtnIdx = -1
	private let CountMainButtons = 2
	private var m_pCurrentController:MyVC? = nil
	private var m_cUnprocessedDocs = 0,m_cUnreadDocs = 0

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		GlobDat.deviceUserContactId = Utils.prefsGetInteger(Utils.createUniqDeviceUserContactKey())
	}

	override func viewDidLoad()
	{
		super.viewDidLoad()
		initLoad()
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		
		setNavigationTitle()
		
		setLogo()

		SynchFuncs.synchProgress_AddToView(self.view)
		if m_pCurrentController != nil {setProgressYOrigin(m_pCurrentController!.getProgressOrigin())}
	}

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)

		if !m_bFirstTimeInit
		{
			m_bFirstTimeInit = true
			self.performSelector(onMainThread: #selector(self.firstTimeInit), with: nil, waitUntilDone: true)//called here for in case Exception alert shown
		}
	}
	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}

	func initLoad()
	{
		btnsMain[0] = m_btnDocuments
		btnsMain[1] = m_btnAcquintance
		self.navigationController?.navigationBar.topItem!.title = "DoXLogic"
		addNavigationIcons()
		let nc = NotificationCenter.`default`
		nc.addObserver(self, selector:#selector(self.processSynchronizationFinished), name:NSNotification.Name(rawValue:GlobDat.kSynchronizationFinished), object:nil)
		nc.addObserver(self, selector:#selector(self.processSynchronizationPortion), name:NSNotification.Name(rawValue:GlobDat.kSynchronizationPortion), object:nil)
		nc.addObserver(self, selector:#selector(self.processEClassLoaded), name:NSNotification.Name(rawValue:GlobDat.kEClassLoaded), object:nil)
		nc.addObserver(self, selector:#selector(self.processResignActive), name:NSNotification.Name.UIApplicationWillResignActive, object:nil)
		nc.addObserver(self, selector:#selector(self.processNavigationTitleChanged), name:NSNotification.Name(rawValue:GlobDat.kNavigationTitleChanged), object:nil)
		nc.addObserver(self, selector:#selector(self.processProgressOrigin), name:NSNotification.Name(rawValue:GlobDat.kProgressOriginShouldChange), object:nil)
		nc.addObserver(self, selector:#selector(self.updateUnprocessedDocsCounter), name:NSNotification.Name(rawValue:GlobDat.kUnprocessedDocsCounter), object:nil)
		nc.addObserver(self, selector:#selector(self.updateUnreadDocsCounter), name:NSNotification.Name(rawValue:GlobDat.kUnreadDocsCounter), object:nil)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if keyPath == "bounds" && context == &ctx1
		{
			m_btnDocuments.roundCorners(7,[.topLeft , .bottomLeft])
		}
		else if keyPath == "bounds" && context == &ctx2
		{
			m_btnAcquintance.roundCorners(7,[.topRight , .bottomRight])
		}
	}

	deinit
	{
		m_btnDocuments.removeObserver(self, forKeyPath: "bounds", context: &ctx1)
		m_btnAcquintance.removeObserver(self, forKeyPath: "bounds", context: &ctx2)
	}

	private var ctx1 = 0,ctx2 = 0
	@objc func firstTimeInit()
	{
		Utils.createFilesDir()

		m_btnDocuments.roundCorners(7,[.topLeft , .bottomLeft])
		m_btnDocuments.addObserver(self, forKeyPath:"bounds", options: .new, context:&ctx1)

		m_btnAcquintance.roundCorners(7,[.topRight , .bottomRight])
		m_btnAcquintance.addObserver(self, forKeyPath:"bounds", options: .new, context:&ctx2)

		EClasses.reset()
		EClasses.loadFromStore()

		let storyboard = UIStoryboard(name: "main", bundle: nil)
		m_pDocsListViewController = storyboard.instantiateViewController(withIdentifier:"DocListView") as! DocsListViewController
		m_pDocsListViewController.m_moc = m_moc
		m_pDocsListViewController.view.isHidden = false//force view creation

		m_pAcquListViewController = storyboard.instantiateViewController(withIdentifier:"AcquListView") as! AcquListViewController
		m_pAcquListViewController.m_moc = m_moc
		m_pAcquListViewController.view.isHidden = false//force view creation

		if EClasses.count() > 0
		{
			m_pDocsListViewController.createClassifierButtons()
			m_pDocsListViewController.updateData()
			m_pAcquListViewController.updateData()
		}
		let savedPressedMainButtonIdx = Utils.prefsGetInteger(Utils.createUniq_MainButtonIdxKey())-1
		if savedPressedMainButtonIdx != -1
		{
			switchViews(savedPressedMainButtonIdx)
			updateMainButtonsBackground()
		}
	}

	func addNavigationIcons()
	{
		let rct = CGRect(x:0,y:0,width:GlobDat.cxNavItem,height:GlobDat.cxNavItem)
		m_refreshButton.frame = rct
		m_refreshButton.addTarget(self, action:#selector(self.refreshPressed), for:UIControlEvents.touchUpInside)
		m_refreshButton.setImage(UIImage(named:"refresh"),for:UIControlState.normal)
		m_refreshButton.isHidden = false

		m_progressButton.frame = rct
		m_progressButton.addTarget(self, action:#selector(self.progressButtonPressed), for:UIControlEvents.touchUpInside)
		m_progressButton.setImage(UIImage(named:""),for:UIControlState.normal)
		m_progressButton.isHidden = true

		let superForButtons = UIView(frame:rct)
		superForButtons.addSubview(m_refreshButton)
		superForButtons.addSubview(m_progressButton)

		m_messagesButton.frame = rct
		m_messagesButton.addTarget(self, action:#selector(self.progressButtonPressed), for:UIControlEvents.touchUpInside)
		m_messagesButton.setImage(UIImage(named:"messages"),for:UIControlState.normal)
		m_messagesButton.isHidden = true

		self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView:superForButtons),UIBarButtonItem(customView:m_messagesButton)]
	}

	@objc func refreshPressed()
	{
		SynchFuncs.synchProgress_Create(false)
		SynchFuncs.synchProgress_AddToView(self.view)

		DispatchQueue.global(qos: .background).async(execute:
		{
			self.doSynchronization()
		})
	}

	func doSynchronization()
	{
		Synchronizer().doSynchronization()
	}

	@objc func progressButtonPressed()
	{
	}

	func updateMainButtonsBackground()
	{
		var clr1 = UIColor.clear,clr2 = UIColor.clear

		if pressedMainBtnIdx == -1
		{
			clr1 = ClrDef.clrClassifBtn1
			clr2 = ClrDef.clrClassifBtn1
		}
		else
		{
			let clrImg = UIColor(patternImage:UIImage(named:"button_selected.png")!)
			if pressedMainBtnIdx == 0
			{
				clr1 = clrImg
				clr2 = ClrDef.clrClassifBtn1
			}
			else if pressedMainBtnIdx == 1
			{
				clr1 = ClrDef.clrClassifBtn1
				clr2 = clrImg
			}
		}
		
		m_btnDocuments.backgroundColor = clr1
		m_btnAcquintance.backgroundColor = clr2
		
		for i in 0..<CountMainButtons
		{
			var clr = ClrDef.clrText1
			if i == pressedMainBtnIdx {clr = UIColor.white}
			for j in 1...3
			{
				if let lbl = btnsMain[i]!.viewWithTag(j) as? UILabel {lbl.textColor = clr}
			}
		}
	}

	func switchViews(_ idx:Int)
	{
		if m_pCurrentController != nil
		{
			m_pCurrentController!.collapseSlidings()
			//m_pCurrentController!.view.isHidden = true
			m_pCurrentController!.view.removeFromSuperview()
			m_pCurrentController!.removeFromParentViewController()
		}
		if pressedMainBtnIdx == idx
		{
			pressedMainBtnIdx = -1
			m_pCurrentController = nil
		}
		else
		{
			var newCurrentController:MyVC? = nil
			pressedMainBtnIdx = idx
			switch pressedMainBtnIdx
			{
				case 0 :
					newCurrentController = m_pDocsListViewController
					break
				case 1 :
					newCurrentController = m_pAcquListViewController
					break
				default :
					break
			}

			if newCurrentController != nil
			{
				addChildViewController(newCurrentController!)
				newCurrentController!.view.frame = m_superForLists.bounds
				m_superForLists.addSubview(newCurrentController!.view)
			}
			m_pCurrentController = newCurrentController
		}
		setNavigationTitle()
		Utils.prefsSet(pressedMainBtnIdx+1,Utils.createUniq_MainButtonIdxKey())
		setLogo()
		let newProgressOrigin = (m_pCurrentController != nil ? m_pCurrentController!.getProgressOrigin() : 0)
		setProgressYOrigin(newProgressOrigin)
	}

	func setNavigationTitle()
	{
		var navTitle = ""
		if m_pCurrentController == nil
		{
			navTitle = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as! String
		}
		else {navTitle = m_pCurrentController!.getNavigationTitle()}
		self.navigationController?.navigationBar.topItem?.title = navTitle
	}

	func setProgressYOrigin(_ newOrigin:CGFloat)
	{
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			let touchBeganPoint = touch.location(in:m_superForMainButtons)
			
			for i in 0..<CountMainButtons
			{
				if btnsMain[i]!.frame.contains(touchBeganPoint)
				{
					switchViews(i)
					updateMainButtonsBackground()
					return
				}
			}
		}
	}

	@objc func processSynchronizationFinished(notification: NSNotification)
	{
		if EClasses.count() > 0
		{
			m_pDocsListViewController.updateData()
			m_pAcquListViewController.updateData()
		}
	}
	
	@objc func processSynchronizationPortion(notification: NSNotification)
	{
		if EClasses.count() > 0
		{
			m_pDocsListViewController.updateData()
		}
	}
	
	@objc func processEClassLoaded(notification: NSNotification)
	{
		EClasses.loadFromStore()
	}
	
	@objc func processResignActive(notification: NSNotification)
	{
		UIApplication.shared.applicationIconBadgeNumber = m_cUnprocessedDocs
	}
	
	@objc func processNavigationTitleChanged(notification: NSNotification)
	{
		setNavigationTitle()
	}
	
	@objc func processProgressOrigin(notification: NSNotification)
	{
	}
	
	@objc func updateUnprocessedDocsCounter(notification: NSNotification)
	{
		let counter = notification.object as! Int
		if counter != m_cUnprocessedDocs
		{
			m_cUnprocessedDocs = counter
			Utils.runOnUI
			{
				(self.m_btnDocuments.viewWithTag(1) as! UILabel).text = String(format:"%d",self.m_cUnprocessedDocs)
			}
		}
	}
	
	@objc func updateUnreadDocsCounter(notification: NSNotification)
	{
		let counter = notification.object as! Int
		if counter != m_cUnreadDocs
		{
			m_cUnreadDocs = counter
			Utils.runOnUI
			{
				(self.m_btnAcquintance.viewWithTag(1) as! UILabel).text = String(format:"%d",self.m_cUnreadDocs)
			}
		}
	}

	func setLogo()
	{
		if m_pCurrentController == nil
		{
			let logoPath = Bundle.main.path(forResource: "logo", ofType: "png")!
			if FileManager.default.fileExists(atPath:logoPath)
			{
				m_logoImageView.image = nil
				let img = UIImage(contentsOfFile:logoPath)
				let imgSize = img!.size
				let originX = (self.view.frame.size.width-imgSize.width)/2
				let deltaOriginY = m_superForMainButtons.frame.origin.y + m_superForMainButtons.frame.size.height
				let originY = deltaOriginY + (self.view.frame.size.height-deltaOriginY-imgSize.height)/2
				let frame = CGRect(x:originX,y:originY,width:imgSize.width,height:imgSize.height)
				m_logoImageView.frame = frame
				m_logoImageView.image = img
			}
			else {m_logoImageView.image = nil}
		}
		else {m_logoImageView.image = nil}
		m_logoImageView.isHidden = (m_logoImageView.image == nil)
	}
}
