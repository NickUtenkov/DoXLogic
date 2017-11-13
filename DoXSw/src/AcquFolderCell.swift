//
//  AcquFolderCell.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 03/08/2017.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class AcquFolderCell : UITableViewCell
{
	@IBOutlet weak var folderImage:UIImageView!
	@IBOutlet weak var folderName:UILabel!
	@IBOutlet var constraintImageOffset:NSLayoutConstraint!
}
