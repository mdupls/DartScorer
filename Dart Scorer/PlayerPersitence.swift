//
//  PlayerManager.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreData

class PlayerPersistence {
    
    private static let entityName = "Player"
    
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func createPlayer(with name: String) -> Player? {
        if let managedObject = storage.writer(entityName: PlayerPersistence.entityName) as? Player {
            managedObject.name = name
            
            storage.save()
            
            return managedObject
        }
        return nil
    }
    
    func players() -> [Player] {
        let managedObjects = storage.reader(entityName: PlayerPersistence.entityName)
        
        return managedObjects as? [Player] ?? []
    }
    
    func player(with name: String) -> Player? {
        let predicate = NSPredicate(format: "name == %@", name)
        let managedObjects = storage.reader(entityName: PlayerPersistence.entityName, predicate: predicate)
        
        return managedObjects.first as? Player
    }
    
    func delete(players: [Player]) {
        storage.delete(managedObjects: players)
        storage.save()
    }
    
}
