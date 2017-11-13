//
//  SynchFuncs.swift
//  DoXSw
//
//  Created by Nick Utenkov on 02/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class SynchFuncs
{
	static var pSP:SynchProgress? = nil
	static func synchProgress_Create(_ bHidden:Bool)
	{
		if pSP == nil
		{
			pSP = SynchProgress()
			var bHiddenLocal = bHidden
			if !bHiddenLocal {bHiddenLocal = Utils.prefsGetBool(Utils.createUniq_showProgressKey())}
			pSP?.view.isHidden = bHiddenLocal
		}
	}

	static func synchProgress_AddToView(_ viewToAddTo:UIView)
	{
		if pSP != nil
		{
			let synchView = pSP!.view!
			if synchView.superview != nil {synchView.removeFromSuperview()}
			viewToAddTo.addSubview(synchView)
		}
	}

	static func synchProgress_Destroy(_ bDelayBecauseOfError:Bool = false)
	{
		if pSP != nil
		{
			var delay:TimeInterval = 0
			var animDuration:CFTimeInterval
			if !bDelayBecauseOfError
			{
				delay = 2
				animDuration = 1.0
			}
			else
			{
				delay = 3.5
				animDuration = 3.0
			}

			Utils.runOnUI
			{
				var frameSynch = pSP!.superView0.frame
				frameSynch.origin.y = -frameSynch.size.height-100
				if bDelayBecauseOfError {pSP!.superView0.backgroundColor = UIColor.red}

				UIView.beginAnimations(nil,context:nil)
				UIView.setAnimationDuration(animDuration)
				pSP!.superView0.frame = frameSynch
				UIView.commitAnimations()
			}

			pSP!.m_timerDelay = delay
			pSP!.performSelector(onMainThread: #selector(SynchProgress.startTimerForDelayedRelease), with: nil, waitUntilDone: false)
		}
	}

	static func synchProgress_updatePartialHeader(_ text:String)
	{
		if pSP != nil
		{
			Utils.runOnUI
			{
				pSP!.m_labelHeader_Partial.text = text
				CATransaction.flush()
			}
		}
	}

	static func synchProgress_updatePartialText(_ text:String)
	{
		Utils.runOnUI{pSP!.m_labelText_Partial.text = text}
	}

	static func synchProgress_updatePartialPercentage(_ percent:Int)
	{
		if pSP != nil
		{
			Utils.runOnUI
			{
				let newWidth = (pSP!.m_progressPartial_BackgroundView.frame.size.width-2)*CGFloat(percent)/100.0
				pSP!.m_progressPartial_ValueView.setWidth(newWidth)
			}
		}
	}

	static func synchProgress_updatePartialTimeLeft(_ seconds:Int)
	{
		if pSP != nil
		{
			Utils.runOnUI
			{
				let strTimeLeft = String(format:"strTimeLeft".localized,Utils.timeToString(seconds))
				pSP!.m_labelRemain_Partial.text = strTimeLeft
			}
		}
	}

	static func synchProgress_resetPartialTimeLeft()
	{
		if pSP != nil
		{
			Utils.runOnUI{pSP!.m_labelRemain_Partial.text = ""}
		}
	}

	static func synchProgress_updateTotalPercentage(_ percent:Int)
	{
		//print("synchProgress_updateTotalPercentage",percent)
		if pSP != nil
		{
			Utils.runOnUI
			{
				pSP!.m_labelText_Total.text = String(format:"%d%%",percent)
				let newWidth = (pSP!.m_progressTotal_BackgroundView.frame.size.width-2)*CGFloat(percent)/100.0
				pSP!.m_progressTotal_ValueView.setWidth(newWidth)
			}
		}
	}

	static func synchProgress_updateTotalTimeLeft(_ seconds:Int)
	{
		if pSP != nil
		{
			Utils.runOnUI{pSP!.m_labelRemain_Total.text = Utils.timeToString(seconds)}
		}
	}

	static func synchProgress_toggleView()
	{
		if pSP != nil
		{
			//if (pSynchProgress2.view.hidden) [pSynchProgress2 animateFromProgressButton]
			//else [pSynchProgress2 animateToProgressButton]
		}
	}

	static func synchProgress_refresh()
	{
		if pSP != nil
		{
			Utils.runOnUI
			{
				pSP!.view.setNeedsDisplay()
				CATransaction.flush()
			}
		}
	}

	static func synchProgress_setYOrigin(_ newOrigin:CGFloat)
	{
		if pSP != nil
		{
			Utils.runOnUI{pSP!.superView0.setYOrigin(newOrigin)}
		}
	}

	static func synchProgress_switchToView2()
	{
		if pSP != nil
		{
			Utils.runOnUI{pSP!.switchToView2()}
		}
	}

	static func synchProgress_setNull()
	{
		pSP = nil
	}
}
