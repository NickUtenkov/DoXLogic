//
//  ClassifierButton.swift
//  DoXSw
//
//  Created by Nick Utenkov on 04/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class ClassifierButton: UIView
{
	var eClass = 0,folderId = 0
	var btnName = ""
	var cProcessed = 0,cUnprocessed = 0
	var offset = Array(repeating:CGFloat(),count:2)
	var nOrder = 0
	static let kClassifierButtonPressed = "ClassifierButtonPressed"

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:ClassifierButton.kClassifierButtonPressed),object:self)
	}

	func createPrefsName(_ idxList:Int) -> String
	{
		return String(format:"%@_ClsBtnScroll%d_%d_%d",Utils.createUniqUserKey(),eClass, folderId, idxList)
	}

	func saveScrollOffsets()
	{
		for i in 0..<2
		{
			Utils.prefsSet(Float(offset[i]),createPrefsName(i))
		}
	}

	func restoreScrollOffsets()
	{
		for i in 0..<2
		{
			offset[i] = CGFloat(Utils.prefsGetFloat(createPrefsName(i)))
		}
	}

	func setOffset(_ value:CGFloat,_ idxList:Int)
	{
		offset[idxList] = value
		saveScrollOffsets()//todo - not optimal
	}

	func getOffset(_ idxList:Int)-> CGFloat
	{
		return offset[idxList]
	}
}
