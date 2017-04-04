//
//  GamePersistence.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreData

class GamePersitence {
    
    private static let entityName = "Game"
    
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func save(game: CoreGame?) {
        // Ensure only 1 entry exists in storage.
        reset()
        
        if let game = game, let managedObject = storage.writer(entityName: GamePersitence.entityName) as? GameEntity {
            managedObject.name = game.name
            
            storage.save()
        }
    }
    
    func get() -> Game? {
//        if let managedObject = storage.reader(entityName: GamePersitence.entityName).last as? GameEntity {
//            if let name = managedObject.name {
//                return Player(name: name)
//            }
//        }
        return nil
    }
    
    func reset() {
        storage.delete(entityName: GamePersitence.entityName)
        storage.save()
    }
    
}
