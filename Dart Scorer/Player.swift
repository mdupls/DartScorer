//
//  Player.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

public extension Player {
    
//    public var description: String {
//        if gamesPlayed > 0 {
//            let winRatio: Int = Int((wins / gamesPlayed) * 100)
//            return "Player: \(name) win ratio: \(winRatio)"
//        }
//        return "Player: \(name)"
//    }
    
}

class GamePlayer {
    
    let player: Player
    
    var scores: [Int: Score] = [:] // Each round has a score
    
    var name: String { return player.name! }
    
    init(player: Player) {
        self.player = player
    }
    
    func hits(for targetValue: Int, upTo round: Int? = nil) -> Int {
        if let round = round {
            var hits: Int = 0
            for r in 0 ... round {
                if let roundHits = scores[r]?.totalHits(for: targetValue) {
                    hits += roundHits
                }
            }
            return hits
        }
        return scores.reduce(0) { (result, item: (key: Int, value: Score)) -> Int in
            return result + item.value.totalHits(for: targetValue)
        }
    }
    
    func score() -> Score {
        let score = Score()
        
        return scores.reduce(score, { (result, item: (key: Int, value: Score)) -> Score in
            if !item.value.bust {
                result.add(score: item.value)
            }
            return result
        })
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
