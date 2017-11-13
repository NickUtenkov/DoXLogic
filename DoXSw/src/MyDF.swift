//
//  MyDF.swift
//  DoXSw
//
//  Created by Nick Utenkov on 28/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation

final class MyDF
{
	static let df8:DateFormatter =
	{
		let _df8 = DateFormatter()
		_df8.dateFormat = "yyyyMMdd"
		return _df8
	}()

	static let df14:DateFormatter =
	{
		let _df14 = DateFormatter()
		_df14.dateFormat = "yyyyMMddHHmmss"
		return _df14
	}()

	static let df17:DateFormatter =
	{
		let _df17 = DateFormatter()
		_df17.dateFormat = "yyyyMMddHHmmssSSS"
		return _df17
	}()

	static let dfDateOnly:DateFormatter =
	{
		let _dfDateOnly = DateFormatter()
		_dfDateOnly.dateFormat = "dd.MM.yyyy"
		return _dfDateOnly
	}()
	
	static let dfShortShort:DateFormatter =
	{
		let dfShortShort = DateFormatter()
		dfShortShort.formatterBehavior = .behavior10_4
		dfShortShort.dateStyle = .short
		dfShortShort.timeStyle = .short
		dfShortShort.locale = Locale(identifier:Locale.preferredLanguages[0])
		return dfShortShort
	}()
}
