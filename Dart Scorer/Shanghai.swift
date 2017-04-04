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
    let rounds: Int
    
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
        self.rounds = config.rounds ?? 0
    }
    
    // MARK: Private
    
    func maximumPointsPossible(from round: Int) -> Int {
        var sum = 0
        if let sequentialTargets = config.sequentialTargets {
            for r in round ..< rounds {
                let targets = sequentialTargets[r]
                
                let maxTarget = targets.reduce(0, { (result, value) -> Int in
                    if value > result {
                        return value
                    }
                    return result
                })
                
                let multiplier = config.isBullseye(value: maxTarget) ? Section.double.rawValue : Section.triple.rawValue
                
                sum += maxTarget * multiplier * config.throwsPerTurn
            }
        }
        return sum
    }
    
    func hasWon(game: CoreGame, player: GamePlayer, round: Int) -> ScoreResult? {
        let players = rank(players: game.players)
        
        let remainingMaxPoints = maximumPointsPossible(from: round)
        
        if players.count == 1 {
            if round == rounds - 1 {
                return .won
            }
        } else {
            if players[0].score().sum() > players[1].score().sum() + remainingMaxPoints {
                return .won
            }
        }
        
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
            
            return hasWon(game: game, player: player, round: round)
        }
        return nil
    }
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        score.unHit(target: target)
        
        return .ok
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func score(forRound roundScore: Score, total totalScore: Score) -> String {
        let roundTotal = roundScore.sum()
        let total = totalScore.sum()
        
        if roundTotal > 0 {
            return "\(total - roundTotal) + \(roundTotal) = \(total)"
        }
        return "\(total)"
    }
    
    func score(for score: Score) -> Int {
        return score.sum()
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players.sorted(by: { (player1, player2) -> Bool in
            return player1.score().sum() > player2.score().sum()
        })
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: ShanghaiGame, round: Int) -> Bool {
        return game.targets[round][value] ?? false
    }
    
}
