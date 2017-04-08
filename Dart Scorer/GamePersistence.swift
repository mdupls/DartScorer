//
//  GamePersistence.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreData

class GamePersistence {
    
    private static let entityName = "Game"
    
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func save(game: String) {
//        if let managedObject = storage.writer(entityName: GamePersistence.entityName) as? GameEntity {
//            managedObject.name = game
//            
//            storage.save()
//        }
    }
    
    func game(with name: String) -> GameEntity? {
        let predicate = NSPredicate(format: "name == %@", name)
        let managedObjects = storage.reader(entityName: GamePersistence.entityName, predicate: predicate)
        
        return managedObjects.first as? GameEntity
    }
    
}
