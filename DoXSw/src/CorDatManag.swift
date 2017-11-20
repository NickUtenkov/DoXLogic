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
	private(set) lazy var persistentContainer:NSPersistentContainer =
	{[unowned self] in
		let pc = NSPersistentContainer(name: Utils.getDBName(),managedObjectModel:getModel())
		pc.loadPersistentStores
		{ (_, error) in
			if let error = error
			{
				fatalError("Failed to load Core Data stack: \(error)")
			}
		}
		print("db URL",NSPersistentContainer.defaultDirectoryURL())
		//Configure automatic migration.
		/*let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
		do
		{
			try pc.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: NSPersistentContainer.defaultDirectoryURL(), options: options)
		}
		catch
		{
			//Report any error we got.
			let failureReason = "There was an error creating or loading the application's saved data."
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
			dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			//abort() causes the application to generate a crash log and terminate.
			//You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}*/
		pc.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		pc.viewContext.undoManager = nil

		return pc
	}()

	func getModel() -> NSManagedObjectModel
	{
		let modelURL = Bundle.main.url(forResource: "DoXLogic", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}
	
	func createWorkerContext() -> NSManagedObjectContext
	{
		let moc:NSManagedObjectContext = persistentContainer.newBackgroundContext()
		// Avoid using default merge policy in multi-threading environment:
		// when we delete (and save) a record in one context,
		// and try to save edits on the same record in the other context before merging the changes,
		// an exception will be thrown because Core Data by default uses NSErrorMergePolicy.
		// Setting a reasonable mergePolicy is a good practice to avoid that kind of exception.
		moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		// In OS X, a context provides an undo manager by default
		// Disable it for performance benefit
		moc.undoManager = nil
		return moc
	}
	
	func saveContext(_ moc:NSManagedObjectContext)
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

	func createPrivateContext() -> NSManagedObjectContext
	{//redo - not use
		return createWorkerContext()
	}

	func savePrivateContext(_ moc:NSManagedObjectContext)
	{//redo - not use
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
