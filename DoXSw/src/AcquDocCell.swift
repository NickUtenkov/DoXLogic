//
//  AcquDocCell.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 03/08/2017.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class AcquDocCell : TouchPointCell
{
	@IBOutlet weak var imageBadge:UIImageView!
	@IBOutlet weak var imageMark:UIImageView!
	@IBOutlet weak var docHeader:UILabel!
	@IBOutlet weak var superForStamp:UIView!
	@IBOutlet weak var stampImage:UIImageView!//subview of superForStamp
	@IBOutlet weak var stampDate:UILabel!//subview of superForStamp
	@IBOutlet weak var imagePriority:UIImageView!
	//views numbers for constraints : docHeader - 1,superForStamp - 2,imagePriority - 3,superview - 4
	@IBOutlet var constraint1To2:NSLayoutConstraint!//priority 1000
	@IBOutlet var constraint1To3:NSLayoutConstraint!//priority 999
	@IBOutlet var constraint2To3:NSLayoutConstraint!//priority 1000
	@IBOutlet weak var docDateDeliver:UILabel!
	@IBOutlet weak var docTitle:UILabel!
	@IBOutlet weak var line1:UIView!
	@IBOutlet weak var line2:UIView!
}
