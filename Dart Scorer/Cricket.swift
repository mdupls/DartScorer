//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class CricketGame {
    
    let config: Config
    let targets: [Int: Bool]
        
    init(config: Config) {
        self.config = config
        
        var targets: [Int: Bool] = [:]
        for value in config.targets {
            targets[value] = true
        }
        self.targets = targets
    }
    
    func hasWon(player: GamePlayer) -> ScoreResult? {
        for value in config.targets {
            if player.score.totalHits(for: value) < 3 {
                return nil
            }
        }
        return .won
    }
    
}

extension CricketGame: Game {
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        var result: ScoreResult?
        let score = player.scores[round]!
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
                
                result = hasWon(player: player) ?? target.result(in: game) ?? target.result(for: player) ?? .ok
            }
        }
        return result
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self) else {
            return .closed
        }
        
        guard !target.isClosed(in: game) else {
            return .closed
        }
        
        guard !target.isOpen(for: player) else {
            return .open
        }
        
        return .initial
    }
    
    func score(forRound roundScore: Score, total totalScore: Score) -> String {
        let result = totalScore.cricketSum(round: roundScore, hitsRequired: config.targetHitsRequired ?? 0)
        
        let roundTotal = result.round
        let total = result.total
        
        if roundTotal > 0 {
            return "\(total - roundTotal) + \(roundTotal) = \(total)"
        }
        return "\(total)"
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
    }
    
}

fileprivate extension Score {
    
    func cricketSum(round score: Score, hitsRequired: Int) -> (round: Int, total: Int) {
        var totalMap: [Int: Int] = [:]
        targets.forEach {
            if let hits = totalMap[$0.value] {
                totalMap[$0.value] = hits + $0.section.rawValue
            } else {
                totalMap[$0.value] = $0.section.rawValue
            }
        }
        
        var roundMap: [Int: Int] = [:]
        score.targets.forEach {
            if let hits = roundMap[$0.value] {
                roundMap[$0.value] = hits + $0.section.rawValue
            } else {
                roundMap[$0.value] = $0.section.rawValue
            }
        }
        
        let round = roundMap.reduce(0) { (result, item: (key: Int, value: Int)) -> Int in
            let totalHits = totalMap[item.key] ?? 0
            if totalHits > hitsRequired {
                let roundHitsNeeded = hitsRequired - (totalHits - item.value)
                if roundHitsNeeded < 0 {
                    return result + item.value * item.key
                }
                let roundHits = item.value - roundHitsNeeded
                if roundHits > 0 {
                    return result + roundHits * item.key
                }
            }
            return result
        }
        
        let total = totalMap.reduce(0) { (result, item: (key: Int, value: Int)) -> Int in
            let hits = item.value
            if hits > hitsRequired {
                return result + (hits - hitsRequired) * item.key
            }
            return result
        }
        
        return (round: round, total: total)
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: CricketGame) -> Bool {
        return game.targets[value] ?? false
    }
    
    func isClosed(in game: CoreGame) -> Bool {
        for player in game.players {
            if player.score.totalHits(for: value) < 3 {
                return false
            }
        }
        return true
    }
    
    func isOpen(for player: GamePlayer) -> Bool {
        return player.score.totalHits(for: value) >= 3
    }
    
    func result(in game: CoreGame) -> ScoreResult? {
        return isClosed(in: game) ? .close : nil
    }
    
    func result(for player: GamePlayer) -> ScoreResult? {
        return isOpen(for: player) ? .open : nil
    }
    
}
