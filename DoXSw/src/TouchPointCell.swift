//
//  TouchPointCell.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 08/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

class TouchPointCell : UITableViewCell
{
	var m_pt = CGPoint.zero

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = event?.allTouches?.first
		{
			m_pt = touch.location(in:self)
		}
		super.touchesBegan(touches,with:event)
	}
}
