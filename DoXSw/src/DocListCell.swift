//
//  DocListCell.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 16/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class DocListCell : UITableViewCell
{
	@IBOutlet weak var docHeader:UILabel!
	@IBOutlet weak var superForStamp:UIView!
	@IBOutlet weak var stampImage:UIImageView!//subview of superForStamp
	@IBOutlet weak var stampDate:UILabel!//subview of superForStamp
	@IBOutlet weak var imagePriority:UIImageView!
	//views numbers for constraints : docHeader - 1,superForStamp - 2,imagePriority - 3,superview - 4
	//can became nil(sometimes) if weak(crash)
	//if isActive is false and constraint is weak - constraint will be removed from view constraints array
	@IBOutlet var constraint1To2:NSLayoutConstraint!//priority 1000
	@IBOutlet var constraint1To3:NSLayoutConstraint!//priority 999
	//@IBOutlet var constraint1To4:NSLayoutConstraint!//priority 998 - not deactivating
	@IBOutlet var constraint2To3:NSLayoutConstraint!//priority 1000
	//@IBOutlet var constraint2To4:NSLayoutConstraint!//priority 999 - not deactivating
	//@IBOutlet var constraint3To4:NSLayoutConstraint!//priority 1000 - not deactivating
	@IBOutlet weak var docAddressOrCor:UILabel!
	@IBOutlet weak var docDateDeliver:UILabel!
	@IBOutlet weak var docTitle:UILabel!
	@IBOutlet weak var tasksLabel:UILabel!
	@IBOutlet weak var line1:UIView!
	@IBOutlet weak var line2:UIView!
}
