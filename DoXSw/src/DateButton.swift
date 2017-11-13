//
//  DateButton.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 24/04/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation

final class DateButton : UIView
{
	@IBOutlet weak var lblTitle:UILabel!
	@IBOutlet weak var lblCount:UILabel!
	@objc var bUsing:Bool = false
	var minDate:Date = Date(),maxDate:Date = Date()
	@objc var count:Int = 0
	static let kDateButtonPressed = "DateButtonPressed"

	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:DateButton.kDateButtonPressed),object:self)
	}
}
