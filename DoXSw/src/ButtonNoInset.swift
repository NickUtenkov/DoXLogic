//
//  ButtonNoInset.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 07/08/2017.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class ButtonNoInset : UIButton
{
	override open var intrinsicContentSize: CGSize
	{
		//let sz = CGSize(w:super.intrinsicContentSize.width + (self.contentEdgeInsets.left + self.contentEdgeInsets.right) + (self.titleEdgeInsets.left + self.titleEdgeInsets.right) + (self.imageEdgeInsets.left + self.imageEdgeInsets.right),
		//					h:super.intrinsicContentSize.height + (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom) + (self.titleEdgeInsets.top + self.titleEdgeInsets.bottom) + (self.imageEdgeInsets.top + self.imageEdgeInsets.bottom))
		//let sz = CGSize(w:super.intrinsicContentSize.width,h:super.intrinsicContentSize.height)
		let sz = CGSize(w:super.intrinsicContentSize.width,h:22)
		return sz;
	}
}
