//
//  Player.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GamePlayer {
    
    let team: Team
    
    var scores: [Int: Score] = [:] // Each round has a score
    
    var name: String { return team.teamName ?? "" }
    
    var totalHits: Int {
        return score().totalHits()
    }
    
    init(team: Team) {
        self.team = team
    }
    
    func player(for round: Int) -> Player? {
        let index = round % (team.players?.count ?? 1)
        
        return team.players?.object(at: index) as? Player
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

extension Team {
    
    var teamName: String? {
        return self.name ?? (players?.firstObject as? Player)?.name
    }
    
}
