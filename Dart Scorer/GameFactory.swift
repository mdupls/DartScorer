//
//  GameFactory.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GameFactory {
    
    private let players: [Player]
    
    init(players: [Player]) {
        self.players = players
    }
    
    func createGame(name: String) -> Game {
        let parser = GameParser(name: name)
        let model = parser.model()
        
        return X01Game(model: model, players: players)
    }
    
}
