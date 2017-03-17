//
//  GameFactory.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GameFactory {
    
    init() {
        
    }
    
    func createGame(players: [Player]) -> IGame {
        return X01Game(players: players, sections: 20)
    }
    
}
