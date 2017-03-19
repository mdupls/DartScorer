//
//  Player.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Player {
    
    var name: String
    
    var wins: Int {
        return _wins
    }
    var losses: Int {
        return _losses
    }
    var gamesPlayed: Int {
        return wins + losses
    }
    
    private var _losses: Int = 0
    private var _wins: Int = 0
    
    init(name: String) {
        self.name = name
    }
    
}

extension Player: CustomStringConvertible {
    
    var description: String {
        if gamesPlayed > 0 {
            let winRatio: Int = Int((wins / gamesPlayed) * 100)
            return "Player: \(name) win ratio: \(winRatio)"
        }
        return "Player: \(name)"
    }
    
}

class GamePlayer {
    
    let player: Player
    let score: Score
    
    var name: String { return player.name }
    
    init(player: Player, score: Score) {
        self.player = player
        self.score = score
    }
    
}
