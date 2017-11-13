//
//  CorDatManag.swift
//  DoXSw
//
//  Created by nick on 12/12/16.
//  Copyright © 2016 nick. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager
{
	static let sharedInstance = CoreDataManager()
	
	/*func applicationDocumentsDirectory() -> URL
	{
		let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)//documentDirectory
		return urls[urls.count-1]
	}*/
	func getDBUrl() -> URL
	{
		return URL(fileURLWithPath:Utils.GetDBDir())
	}
	
	func getModel() -> NSManagedObjectModel
	{
		let modelURL = Bundle.main.url(forResource: "DoXLogic", withExtension: "momd")!
		//let ios9modelURL = modelURL.appendingPathComponent("DoXLogic0.mom")
		return NSManagedObjectModel(contentsOf: modelURL)!
	}
	
	private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator =
	{[unowned self] in
		let coordinator:NSPersistentStoreCoordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.getModel())
		let url = self.getDBUrl().appendingPathComponent(Utils.getDBName())
		print("db URL",url)
		var failureReason = "There was an error creating or loading the application's saved data."
		do
		{
			//Configure automatic migration.
			let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		}
		catch
		{
			//Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			//Replace this with code to handle the error appropriately.
			//abort() causes the application to generate a crash log and terminate.
			//You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	private(set) lazy var masterMoc: NSManagedObjectContext =
	{[unowned self] in
		var moc: NSManagedObjectContext?
		//Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
		//This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		moc!.persistentStoreCoordinator = coordinator
		moc!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		moc!.undoManager = nil
		return moc!
	}()

	private(set) lazy var mainMoc: NSManagedObjectContext =
	{[unowned self] in
		var moc: NSManagedObjectContext?
		//Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
		//This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		moc!.parent = self.masterMoc
		return moc!
	}()
	
	func createWorkerContext() -> NSManagedObjectContext
	{
		var moc: NSManagedObjectContext?
		moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		moc!.parent = self.mainMoc
		// Avoid using default merge policy in multi-threading environment:
		// when we delete (and save) a record in one context,
		// and try to save edits on the same record in the other context before merging the changes,
		// an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
		// Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
		moc!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		// In OS X, a context provides an undo manager by default
		// Disable it for performance benefit
		moc!.undoManager = nil
		return moc!
	}
	
	func saveMainContext()
	{
		DispatchQueue.main.async(execute:
		{//else crashes if -com.apple.CoreData.ConcurrencyDebug 1
			if self.mainMoc.hasChanges
			{
				do
				{
					try self.mainMoc.save()
				}
				catch
				{
					//Replace this implementation with code to handle the error appropriately.
					//abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
					let nserror = error as NSError
					NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
					abort()
				}

				self.masterMoc.performAndWait
				{
					do
					{
						try self.masterMoc.save()
					}
					catch
					{
						//Replace this implementation with code to handle the error appropriately.
						//abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
						let nserror = error as NSError
						NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
						abort()
					}
				}
			}
		})
	}
	
	func saveContext(_ moc:NSManagedObjectContext)
	{
		if moc != mainMoc
		{
			if moc.hasChanges
			{
				do
				{
					try moc.save()
				}
				catch
				{
					//Replace this implementation with code to handle the error appropriately.
					//abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
					let nserror = error as NSError
					NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
					abort()
				}
			}
		}
		saveMainContext()
	}

	func createPrivateContext() -> NSManagedObjectContext
	{
		var moc: NSManagedObjectContext?
		moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		// Avoid using default merge policy in multi-threading environment:
		// when we delete (and save) a record in one context,
		// and try to save edits on the same record in the other context before merging the changes,
		// an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
		// Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
		moc!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		// In OS X, a context provides an undo manager by default
		// Disable it for performance benefit
		moc!.undoManager = nil

		moc!.persistentStoreCoordinator = self.persistentStoreCoordinator

		return moc!
	}

	func savePrivateContext(_ moc:NSManagedObjectContext)
	{
		if moc.hasChanges
		{
			do
			{
				try moc.save()
			}
			catch
			{
				//Replace this implementation with code to handle the error appropriately.
				//abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}
}
