//
//  TeamPersistence.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-11.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreData

class TeamPersistence {
    
    private static let entityName = "Team"
    
    private let storage: CoreDataStorage
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    func createTeam(name: String, players: [Player]) -> Team? {
        if let managedObject = storage.writer(entityName: TeamPersistence.entityName) as? Team {
            managedObject.name = name
            managedObject.addToPlayers(NSOrderedSet(array: players))
            
            storage.save()
            
            return managedObject
        }
        return nil
    }
    
    func teams() -> [Team] {
        let managedObjects = storage.reader(entityName: TeamPersistence.entityName)
        
        return managedObjects as? [Team] ?? []
    }
    
    func player(with name: String) -> Player? {
        let predicate = NSPredicate(format: "name == %@", name)
        let managedObjects = storage.reader(entityName: TeamPersistence.entityName, predicate: predicate)
        
        return managedObjects.first as? Player
    }
    
}
