//
//  X01Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class X01Game {
    
    let model: BoardModel
    let config: Config
    
    var goal: Int = 501
    
    private var _finished: Bool = false
    
    init(model: BoardModel, config: Config) {
        self.model = model
        self.config = config
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        let points = score.sum(model: model)
        
        if points == goal {
            return .Won
        } else if points < goal {
            return .OK
        } else {
            return .Bust
        }
    }
    
}

extension X01Game: Game {
    
    func score(player: GamePlayer, target: Target?, round: Int) -> ScoreResult {
        let score = player.scores[round]!
        
        if let target = target, score.hits < config.throwsPerTurn {
            score.hit(target: target)
        }
        
        let totalScore = player.score
        
        print("\(player.name)'s score: \(totalScore.sum(model: model))")
        
        return check(score: totalScore)
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
    }
    
}
