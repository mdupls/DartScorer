//
//  X01Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class X01Game {
    
    let config: Config
    let goal: Int
    let targets: [Int: Bool]
    
    private var _finished: Bool = false
    
    init(config: Config, goal: Int) {
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
        let points = score.sum()
        
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
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
            }
            
            return check(score: player.score(at: round))
        }
        return nil
    }
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        score.unHit(target: target)
        
        return check(score: player.score(at: round))
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func score(forPlayer player: GamePlayer, forRound roundScore: Score, total totalScore: Score) -> String? {
        let roundTotal = roundScore.sum()
        let total = totalScore.sum()
        
        if roundTotal > 0 {
            return "\(goal - (total - roundTotal)) - \(roundTotal) = \(goal - total)"
        }
        return "\(goal - total)"
    }
    
    func score(forPlayer player: GamePlayer) -> Int? {
        return goal - player.score().sum()
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
