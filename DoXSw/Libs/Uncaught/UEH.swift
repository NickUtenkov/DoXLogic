//
//  UEH.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 12/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation

final class UEH : NSObject
{
	static private var UncaughtExceptionCount:Int32 = 0
	static private let UncaughtExceptionMaximum:Int32 = 10
	static let AddressesKey = "AddressesKey"
	var bDismissed = false

	static func handleException(_ exc:NSException)
	{
		let exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount)
		if exceptionCount > UncaughtExceptionMaximum {return}
		var userInfo:[AnyHashable : Any] = [:]
		userInfo[AddressesKey] = Thread.callStackSymbols
		let exception = NSException(name: exc.name,reason: exc.reason,userInfo: userInfo)
		LogFile.shared.write(exception)
		let ueh = UEH()
		ueh.performSelector(onMainThread: #selector(ueh.showExceptionAlert), with:exc.reason, waitUntilDone: false)
		ueh.waitAlert()
		Utils.restoreExceptionHandler()
		exit(77)
	}

	static func signalException(_ signal:Int32)
	{
		let exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount)
		if exceptionCount > UncaughtExceptionMaximum {return}
		var userInfo:[AnyHashable : Any] = [:]
		userInfo[AddressesKey] = Thread.callStackSymbols
		let strReason = String(format:"Signal %d was raised.",signal)
		let excName = NSExceptionName("Signal Exception")
		let exception = NSException(name:excName,reason:strReason,userInfo: userInfo)
		LogFile.shared.write(exception)
		let ueh = UEH()
		ueh.performSelector(onMainThread: #selector(ueh.showExceptionAlert), with: strReason, waitUntilDone: false)
		ueh.waitAlert()
		Utils.restoreExceptionHandler()
		exit(77)
	}

	@objc func showExceptionAlert(_ descr:String)
	{
		let strReason = String(format:"Description".localized,descr)
		let alrt = UIAlertController(title:"ProgramCrash".localized,message:strReason,preferredStyle: .alert)
		let okButton = UIAlertAction(title: "Close".localized, style: .default, handler: {_ in self.bDismissed = true})
		alrt.addAction(okButton)
		UIApplication.shared.windows[0].rootViewController?.present(alrt, animated: true, completion: nil)
	}

	func waitAlert()
	{
		var dt = Date.init(timeIntervalSinceNow:0.01)
		repeat
		{
			RunLoop.current.run(until:dt)
			dt += 0.01
		}
		while (!bDismissed)
	}
}
