//
//  CoreDataStorage.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStorage {
    
    var managedObjectContext: NSManagedObjectContext
    
    init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        load(coordinator: coordinator)
    }
    
    private func load(coordinator: NSPersistentStoreCoordinator) {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let docUrl = urls.last else { return }
        
        let url = docUrl.appendingPathComponent("Model.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func reader(entityName: String) -> [AnyObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            fatalError("Could not fetch \(error), \(error.userInfo)")
        }
        return [AnyObject]()
    }
    
    func writer(entityName: String) -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
        return NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
    }
    
    func delete(entityName: String) {
        for item in self.reader(entityName: entityName) {
            if let managedObject = item as? NSManagedObject {
                managedObjectContext.delete(managedObject)
            }
        }
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            fatalError("Failure to save context: \(error)")
        }
    }
    
}
