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
    
    func save(player: Player?) {
        if let player = player, let managedObject = storage.writer(entityName: PlayerPersistence.entityName) as? PlayerEntity {
            managedObject.name = player.name
            
            storage.save()
        }
    }
    
    func get() -> Player? {
        if let managedObject = storage.reader(entityName: PlayerPersistence.entityName).last as? PlayerEntity {
            if let name = managedObject.name {
                return Player(name: name)
            }
        }
        return nil
    }
    
    func getPlayers() -> [Player] {
        let managedObjects = storage.reader(entityName: PlayerPersistence.entityName)
        
        var players: [Player] = []
        managedObjects.forEach {
            if let player = $0 as? PlayerEntity {
                if let name = player.name {
                    players.append(Player(name: name))
                }
            }
        }
        return players
    }
    
}
