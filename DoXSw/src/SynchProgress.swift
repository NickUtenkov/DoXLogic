//
//  SynchProgress.swift
//  DoXSw
//
//  Created by Nick Utenkov on 01/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import UIKit

final class SynchProgress : UIViewController
{
	@IBOutlet weak var superView0:UIView!
	@IBOutlet weak var m_Header:UILabel!
	@IBOutlet weak var m_progressPartial_BackgroundView:UIView!
	@IBOutlet weak var m_progressPartial_ValueView:UIView!
	@IBOutlet weak var m_labelHeader_Total:UILabel!
	@IBOutlet weak var m_progressTotal_BackgroundView:UIView!
	@IBOutlet weak var m_progressTotal_ValueView:UIView!
	@IBOutlet weak var m_labelHeader_Partial:UILabel!
	@IBOutlet weak var m_labelText_Partial:UILabel!
	@IBOutlet weak var m_labelRemain_Partial:UILabel!
	@IBOutlet weak var m_labelText_Total:UILabel!
	@IBOutlet weak var m_labelRemain_Total:UILabel!
	//@IBOutlet weak var m_btnHide:UIButton!
	//@IBOutlet weak var m_switchGlobalHide:UISwitch!
	//@IBOutlet weak var m_labelSwitch:UILabel!
	@IBOutlet weak var m_upperLine:UIView!
	@IBOutlet weak var m_middleLine:UIView!
	@IBOutlet weak var m_bottomLine:UIView!
	@IBOutlet weak var m_btnClose:UIButton!
	private var bMode2 = false
	var m_timerDelay:TimeInterval = 0
	private let cornerRadius:Float = 7.0

	init()
	{
		super.init(nibName: "SynchProgress", bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		m_btnClose.isHidden = true

		m_progressPartial_ValueView.backgroundColor = UIColor(patternImage:UIImage(named:"progrback.png")!)
		m_progressTotal_ValueView.backgroundColor = UIColor(patternImage:UIImage(named:"progrback.png")!)
		
		//m_btnHide.decorate(9,1.0,ClrDef.clrAcqu2Gray)
		//m_btnHide.makeGradient(ClrDef.clrAcqu1Gray.cgColor,ClrDef.clrAcqu2Gray.cgColor)
		
		m_labelHeader_Partial.text = ""
		m_labelText_Partial.text = ""
		m_progressPartial_ValueView.setWidth(0)
		m_labelRemain_Partial.text = ""
		
		m_labelText_Total.text = ""
		m_progressTotal_ValueView.setWidth(0)
		m_labelRemain_Total.text = ""
		
		//m_switchGlobalHide.isOn = Utils.prefsGetBool(Utils.createUniq_showProgressKey())
		
		m_btnClose.makeGradient(ClrDef.clrAcqu1Gray.cgColor,ClrDef.clrAcqu2Gray.cgColor)
	}

	@objc func startTimerForDelayedRelease()
	{
		let timer:Timer = Timer.scheduledTimer(timeInterval:m_timerDelay,target:self,selector: #selector(myRelease),userInfo:nil,repeats:false)
		RunLoop.current.add(timer, forMode: .commonModes)
	}

	@objc func myRelease()
	{
		self.view.removeFromSuperview()
		SynchFuncs.synchProgress_setNull()
	}

	func switchToView2()
	{
		bMode2 = true
		
		var fr = self.view.frame
		fr.origin.y -= 44
		self.view.frame = fr
		fr = superView0.frame
		fr.origin.y += 44
		fr.size.height = 177
		superView0.frame = fr
		
		m_Header.text = "SynchFinishedOK".localized
		//m_btnHide.isHidden = true
		m_btnClose.isHidden = false
		
		m_labelHeader_Total.frame = m_labelHeader_Partial.frame
		m_labelHeader_Partial.isHidden = true
		
		m_progressTotal_BackgroundView.frame = m_progressPartial_BackgroundView.frame
		m_progressPartial_BackgroundView.isHidden = true
		
		/*fr = m_switchGlobalHide.frame
		//fr.origin.y -= 112
		fr.origin.y = 102
		m_switchGlobalHide.frame = fr
		fr = m_labelSwitch.frame
		//fr.origin.y -= 112
		fr.origin.y = 105
		m_labelSwitch.frame = fr*/
		
		m_labelRemain_Partial.isHidden = true
		m_labelRemain_Total.isHidden = true
		m_upperLine.isHidden = true
		m_middleLine.isHidden = true
		m_bottomLine.isHidden = true
		SynchFuncs.synchProgress_updateTotalPercentage(100)
	}

	@IBAction func pressedClose(_ sender: UIButton)
	{
		myRelease()
	}
}
