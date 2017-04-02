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
    
    var scores: [Int: Score] = [:] // Each round has a score
    
    var score: Score {
        let score = Score()
        
        return scores.reduce(score, { (result, item: (key: Int, value: Score)) -> Score in
            result.add(score: item.value)
            
            return result
        })
    }
    
    var name: String { return player.name }
    
    init(player: Player) {
        self.player = player
    }
    
    func score(upTo round: Int) -> Score {
        let score = Score()
        
        for r in 0 ..< round {
            if let roundScore = self.score(for: r) {
                score.add(score: roundScore)
            }
        }
        
        return score
    }
    
    func score(for round: Int) -> Score? {
        return scores[round]
    }
    
}
