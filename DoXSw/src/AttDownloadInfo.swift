//
//  AttDownloadInfo.swift
//  DoXSw
//
//  Created by Nick Utenkov on 28/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

struct AttDownloadInfo
{
	var attId:Int
	var size:UInt64,offset:UInt64

	init(_ attId1:Int,_ size1:UInt64,_ offset1:UInt64)
	{
		attId = attId1
		size = size1
		offset = offset1
	}
}
