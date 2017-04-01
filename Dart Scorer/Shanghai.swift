//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class ShanghaiGame {
    
    let config: Config
    let targets: [[Int: Bool]]
    
    init(config: Config) {
        self.config = config
        
        var targets: [[Int: Bool]] = []
        if let sequentialTargets = config.sequentialTargets {
            for round in sequentialTargets {
                var targetsForRound: [Int: Bool] = [:]
                for value in round {
                    targetsForRound[value] = true
                }
                targets.append(targetsForRound)
            }
        }
        self.targets = targets
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        return .ok
    }
    
}

extension ShanghaiGame: Game {
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
            }
            
            let totalScore = player.score
            
            print("\(player.name)'s score: \(totalScore.sum())")
            
            return check(score: totalScore)
        }
        return nil
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players.sorted(by: { (player1, player2) -> Bool in
            return player1.score.sum() > player2.score.sum()
        })
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: ShanghaiGame, round: Int) -> Bool {
        return game.targets[round][value] ?? false
    }
    
}
