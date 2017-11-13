//
//  ProgressPartialTitle.swift
//  DoXSw
//
//  Created by Nick Utenkov on 24/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class ProgressPartialTitle: Operation
{
	var title = ""
	var m_cGroupRequests = 0

	override func main()
	{
		//print(title)
		Utils.runOnUI{SynchFuncs.synchProgress_updatePartialHeader(self.title)}
		if m_cGroupRequests > 0 {NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:GlobDat.kNewRequestsGroup),object:m_cGroupRequests)}
	}
}
