//
//  MyVC.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 06/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import UIKit

//Can't use protocol because some UIViewController property/functions also need to use
/*protocol DocListInterface
{
	func getProgressOrigin() -> CGFloat
	func getNavigationTitle() ->String
	func updateData()
	func collapseSlidings()
}*/

class MyVC : UIViewController
{
	func getProgressOrigin() -> CGFloat
	{
		return 0
	}
	func getNavigationTitle() ->String
	{
		return ""
	}
	func updateData() {}
	func collapseSlidings() {}
}
