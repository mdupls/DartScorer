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
    let goal: Int
    let targets: [Int: Bool]
    
    private var _finished: Bool = false
    
    init(model: BoardModel, config: Config, goal: Int) {
        self.model = model
        self.config = config
        self.goal = goal
        
        var targets: [Int: Bool] = [:]
        for value in config.targets {
            targets[value] = true
        }
        self.targets = targets
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        let points = score.sum(model: model)
        
        if points == goal {
            return .won
        } else if points < goal {
            return .ok
        } else {
            return .bust
        }
    }
    
}

extension X01Game: Game {
    
    func game(_ game: CoreGame, hit target: Target?, player: GamePlayer, round: Int) -> ScoreResult {
        let score = player.scores[round]!
        
        if let target = target, score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
            }
        }
        
        let totalScore = player.score
        
        print("\(player.name)'s score: \(totalScore.sum(model: model))")
        
        return check(score: totalScore)
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: X01Game, round: Int) -> Bool {
        return game.targets[value] ?? false
    }
    
}
