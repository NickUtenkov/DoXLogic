//
//  DoXSwTests.swift
//  DoXSwTests
//
//  Created by nick on 16/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import XCTest
@testable import DoXLogic

class DoXSwTests: XCTestCase
{
	override func setUp()
	{
		super.setUp()
	}

	override func tearDown()
	{
		super.tearDown()
	}

	func testDateFromString()
	{
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let dt1 = Utils.getDateFromString("20160130")
		let gregorian = NSCalendar(identifier:.gregorian)
		let year = gregorian?.component(NSCalendar.Unit.year, from:dt1!)
		let month = gregorian?.component(NSCalendar.Unit.month, from:dt1!)
		let day = gregorian?.component(NSCalendar.Unit.day, from:dt1!)
		XCTAssertTrue(year == 2016, "year is wrong")
		XCTAssertTrue(month == 1, "month is wrong")
		XCTAssertTrue(day == 30, "day is wrong")
	}

	/*func testPerformanceExample()
	{
		self.measure
		{
		}
	}*/

}
