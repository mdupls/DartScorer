//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

class CricketGame {
    
    let config: Config
    let targets: [Int: Bool]
    let targetHitsRequired: Int
    
    let players: [GamePlayer]
    
    // Mapping of round to another map of player names to points
    fileprivate var points: [Int: [String: Int]]
    
    fileprivate var round: Int = 0
    
    init(config: Config, players: [GamePlayer]) {
        self.config = config
        self.players = players
        
        var targets: [Int: Bool] = [:]
        for value in config.targets {
            targets[value] = true
        }
        self.targets = targets
        self.points = CricketGame.createPointsMap(round: 0, players: players)
        
        targetHitsRequired = config.targetHitsRequired ?? 3
    }
    
    func hasWon(player: GamePlayer) -> ScoreResult? {
        let score = self.score(forPlayer: player)
        
        // A player must have closed all targets.
        for (target, _) in targets {
            if player.hits(for: target) < targetHitsRequired {
                return .ok
            }
        }
        
        // A player must have the highest score.
        for p in players.filter({ $0.name != player.name }) {
            if score < self.score(forPlayer: p) {
                return .ok
            }
        }
        
        return .won
    }
    
    func calculateScores() {
        // Keep a map of open/close targets. A target is closed when all of the states are true.
        var targets: [Int: [Bool]] = [:]
        for value in config.targets {
            let targetState = players.map { _ in
                return false
            }
            targets[value] = targetState
        }
        
        // Mapping of target value to another map of player names to # of hits
        var hits = CricketGame.createHitsMap(targets: self.targets, players: players)
        
        points = CricketGame.createPointsMap(round: round, players: players)
        
        for round in 0 ... round {
            targets.forEach { (target: Int, value: [Bool]) in
                for (index, player) in players.enumerated() {
                    if let roundScore = player.scores[round] {
                        let roundHits = roundScore.totalHits(for: target)
                        
                        if roundHits > 0 {
                            var countHits = true
                            let previousHits = hits[target]?[player.name] ?? 0
                            let totalHits = previousHits + roundHits
                            
                            if totalHits >= targetHitsRequired {
                                targets[target]?[index] = true
                                
                                if let values = targets[target] {
                                    let numberOfClosed = values.reduce(0, { (result, closed) -> Int in
                                        if closed {
                                            return result + 1
                                        }
                                        return result
                                    })
                                    
                                    if numberOfClosed == players.count {
                                        countHits = false
                                    }
                                }
                            }
                            
                            if countHits {
                                var pointHits: Int
                                if previousHits >= targetHitsRequired {
                                    // The player has already opened this target. Count all this rounds hits.
                                    pointHits = roundHits
                                } else {
                                    // Calculate how many hits are worth points this round.
                                    pointHits = max(0, roundHits - (targetHitsRequired - previousHits))
                                }
                                
                                hits[target]?[player.name] = totalHits
                                points[round]?[player.name] = (points[round]?[player.name] ?? 0 ) + pointHits * target
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    // MARK: Private
    
    private static func createHitsMap(targets: [Int: Bool], players: [GamePlayer]) -> [Int: [String: Int]] {
        var scores: [Int: [String: Int]] = [:]
        for (target, _) in targets {
            var hitsForPlayers: [String: Int] = [:]
            for player in players {
                hitsForPlayers[player.name] = 0
            }
            scores[target] = hitsForPlayers
        }
        return scores
    }
    
    private static func createPointsMap(round: Int, players: [GamePlayer]) -> [Int: [String: Int]] {
        var scores: [Int: [String: Int]] = [:]
        for r in 0 ... round {
            var pointsForPlayers: [String: Int] = [:]
            for player in players {
                pointsForPlayers[player.name] = 0
            }
            scores[r] = pointsForPlayers
        }
        return scores
    }
    
}

extension CricketGame: Game {
    
    var rounds: Int? {
        return nil
    }
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        var result: ScoreResult?
        let score = player.scores[round]!
        
        self.round = max(round, self.round)
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
                calculateScores()
                
                result = hasWon(player: player) ?? target.result(in: game) ?? target.result(for: player) ?? .ok
            }
        }
        return result
    }
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        score.unHit(target: target)
        calculateScores()
        
        return .ok
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
    
    func scoreTitle(forPlayer player: GamePlayer, forRound round: Int?) -> String? {
        var roundTotal: Int
        if let round = round {
            roundTotal = points[round]?[player.name] ?? 0
        } else {
            roundTotal = 0
        }
        
        let total = score(forPlayer: player)
        if roundTotal > 0 {
            return "\(total - roundTotal) + \(roundTotal) = \(total)"
        }
        return "\(total)"
    }
    
    func score(forPlayer player: GamePlayer, forRound round: Int? = nil) -> Int {
        let name = player.name
        
        return points.reduce(0) { (result, item: (key: Int, value: [String : Int])) -> Int in
            if let points = item.value[name] {
                return result + points
            }
            return result
        }
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
    }
    
    func scoreViewController() -> UIViewController? {
        let viewController = UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: "cricketScore")
        
        (viewController as? CricketScoreViewController)?.config = config
        
        return viewController
    }
    
}

fileprivate extension Score {
    
    func targetMap() -> [Int: Int] {
        var totalMap: [Int: Int] = [:]
        targets.forEach {
            if let hits = totalMap[$0.value] {
                totalMap[$0.value] = hits + $0.section.rawValue
            } else {
                totalMap[$0.value] = $0.section.rawValue
            }
        }
        return totalMap
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: CricketGame) -> Bool {
        return game.targets[value] ?? false
    }
    
    func isClosed(in game: CoreGame) -> Bool {
        for player in game.players {
            if player.score().totalHits(for: value) < 3 {
                return false
            }
        }
        return true
    }
    
    func isOpen(for player: GamePlayer) -> Bool {
        return player.score().totalHits(for: value) >= 3
    }
    
    func result(in game: CoreGame) -> ScoreResult? {
        return isClosed(in: game) ? .close : nil
    }
    
    func result(for player: GamePlayer) -> ScoreResult? {
        return isOpen(for: player) ? .open : nil
    }
    
}
