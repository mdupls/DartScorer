//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class ShanghaiGame {
    
    let model: BoardModel
    let config: Config
    
    init(model: BoardModel, config: Config) {
        self.model = model
        self.config = config
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        return .OK
    }
    
}

extension ShanghaiGame: Game {
    
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
        return players.sorted(by: { (player1, player2) -> Bool in
            return player1.score.sum(model: model) > player2.score.sum(model: model)
        })
    }
    
}
