//
//  XMLFuncs.swift
//  DoXSw
//
//  Created by nick on 22/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class XMLFuncs
{
	static func getSuccessAttributeValue(_ elem:AEXMLElement) -> Int
	{
		if let attr:String = elem.attributes["success"]
		{
			if attr.bool {return 1}
			else {return 0}
		}
		return -1
	}

	static func getErrorFromErrorNode(_ elem:AEXMLElement) -> String?
	{
		/*
		<assignTaskExecutor
		OperationUID="CC4FEBB8-261A-4C0E-956A-146CFC99B2F6" success="0">
		<error message="Выполнение действия с документом недоступно. Документ используется пользователем: O_Bankovskaya"/>
		</assignTaskExecutor>
		*/
		if let errorNode = elem.children.filter({ $0.name == "error" }).first
		{
			return errorNode.attributes["message"]
		}
		return nil
	}

	static func getVersionFromAttrs(_ attrs: [String : String]) -> Int
	{
		if let version = attrs["_version"]
		{
			return Int(version)!
		}
		return 1
	}
}
