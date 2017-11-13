//
//  SlidingView.swift
//  DoXSw
//
//  Created by Nick Utenkov on 04/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

typealias FuncTypeContentWidthChanged = () -> Void
typealias FuncTypeHeightChanged = () -> Void

final class SlidingView : NSObject
{
	@IBOutlet weak var m_View:UIView!
	@IBOutlet weak var m_contentView:UIView!
	@IBOutlet weak var m_Label:UILabel!
	@IBOutlet weak var m_Sign:UILabel!
	@IBOutlet weak var m_TouchArea:UIView!
	private var m_State:State = .stateCollapsed
	var m_LabelNames:[String] = []
	var m_LabelSigns:[String] = []
	var m_BackImage:UIImage?
	var m_stateLockedPrefsKey = ""
	static let cornerRadius:CGFloat = 7.0
	enum State:Int
	{//https://appventure.me/2015/10/17/advanced-practical-enum-examples
		case stateCollapsed = 0,stateExpanded,stateLocked,stateFillView
	}
	private var ctx1 = 0,ctx2 = 0
	private var bInsideUpdateOrigin = false
	var funcContentWidthChanged:FuncTypeContentWidthChanged? = nil
	var funcHeightChanged:FuncTypeHeightChanged? = nil
	private var contentWidth:CGFloat = 0

	override func awakeFromNib()
	{
		super.awakeFromNib()
		m_State = State.stateCollapsed
	}

	deinit
	{
		m_View.removeObserver(self, forKeyPath: "frame", context: &ctx1)
		m_contentView.removeObserver(self, forKeyPath: "frame", context: &ctx2)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
	{
		if context == &ctx1
		{
			if bInsideUpdateOrigin
			{
				bInsideUpdateOrigin = false
				return
			}
			bInsideUpdateOrigin = true
			updateOrigin(m_View.frame.size.width)
			funcHeightChanged?()
		}
		else if context == &ctx2
		{
			if contentWidth != m_contentView.frame.size.width
			{
				contentWidth = m_contentView.frame.size.width
				funcContentWidthChanged?()
			}
		}
	}

	func didLoad()
	{
		m_View.setShadow(UIColor.gray.cgColor, SlidingView.cornerRadius/CGFloat(2.0),0.8,0,SlidingView.cornerRadius)
		m_Label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2*3.0))

		m_View.addObserver(self, forKeyPath:"frame", options: .new, context:&ctx1)
		m_contentView.addObserver(self, forKeyPath:"frame", options: .new, context:&ctx2)
	}

	func setOriginX(_ xOrigin:CGFloat)
	{
		m_View.setXOrigin(xOrigin)
	}

	func setOriginY(_ yOrigin:CGFloat)
	{
		m_View.setYOrigin(yOrigin)
	}

	func setInitialOriginX(_ outerViewWidth:CGFloat)
	{
		m_View.setXOrigin(-(outerViewWidth-m_TouchArea.frame.size.width))
	}

	func getHeight() -> CGFloat
	{
		return m_View.frame.size.height
	}

	func setHeight(_ newHeight:CGFloat)
	{
		m_View.setHeight(newHeight)
	}

	func getState() -> State
	{
		return m_State
	}

	func setState(_ newState:State)
	{
		if m_State != newState
		{
			m_State = newState
			updateNames()
		}
		let bNewState = (m_State == .stateLocked) ? true : false
		Utils.prefsSet(bNewState,self.m_stateLockedPrefsKey)
	}

	func getTouchWidth() -> CGFloat
	{
		return m_TouchArea.frame.size.width
	}

	private func updateOrigin(_ viewWidth:CGFloat)
	{
		let touchWidth = m_TouchArea.frame.size.width
		
		var originX:CGFloat = 0
		if m_State == .stateCollapsed {originX = -viewWidth+touchWidth}
		else if m_State == .stateExpanded {originX = -touchWidth}
		else if m_State == .stateLocked {originX = 0}
		m_View.setXOrigin(originX)
	}

	func isTouchInside(_ touch:UITouch) -> Bool
	{
		let touchBeganPoint = touch.location(in:m_View)
		//expand touch area
		var frame = m_TouchArea.frame
		frame.origin.x -= m_TouchArea.frame.size.width
		frame.size.width += 2*m_TouchArea.frame.size.width
		
		return frame.contains(touchBeganPoint)
	}

	func updateNames()
	{
		m_Label.text = m_LabelNames[m_State.rawValue]
		m_Sign.text = m_LabelSigns[m_State.rawValue]
	}

	func updateTouchAreaBackgroundColor(_ bDrawAsSelected:Bool)
	{
		if bDrawAsSelected
		{
			if let img = m_BackImage?.scaleToSize(m_TouchArea.frame.size)
			{
				m_TouchArea.backgroundColor = UIColor(patternImage:img)
			}
			m_Label.textColor = UIColor.white
			m_Sign.textColor = UIColor.white
		}
		else
		{
			m_TouchArea.roundCorners(SlidingView.cornerRadius,[.topRight , .bottomRight])//need here(above not need)
			m_TouchArea.backgroundColor = UIColor.white
			m_Label.textColor = ClrDef.clrText1
			m_Sign.textColor = ClrDef.clrText1
		}
	}

	func updateSubviewsYOriginAndHeights(_ newHeight:CGFloat)
	{
		m_View.setHeight(newHeight)

		m_contentView.setYOrigin(0)
		m_contentView.setHeight(newHeight)

		m_Label.setYOrigin((newHeight-m_Label.frame.size.height)/2)
		m_Sign.setYOrigin((newHeight-m_Sign.frame.size.height)/2)

		m_TouchArea.setHeight(newHeight)
		m_TouchArea.roundCorners(SlidingView.cornerRadius,[.topRight , .bottomRight])
	}
}
