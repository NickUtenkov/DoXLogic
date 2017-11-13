//
//  AppDelegate.swift
//  DoXSw
//
//  Created by nick on 16/12/16.
//  Copyright © 2016 Nick Utenkov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate
{
	var window: UIWindow?//removing this var lead to program crash

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
	{
		Utils.installUncaughtExceptionHandler()

		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		//UINavigationBar.appearance().shadowImage = UIImage()//remove shadow

		return true
	}

	func applicationWillResignActive(_ application: UIApplication)
	{
	}

	func applicationDidEnterBackground(_ application: UIApplication)
	{
	}

	func applicationWillEnterForeground(_ application: UIApplication)
	{
	}

	func applicationDidBecomeActive(_ application: UIApplication)
	{
	}

	func applicationWillTerminate(_ application: UIApplication)
	{
		#if false
		self.saveContext()
		#endif
	}
}

