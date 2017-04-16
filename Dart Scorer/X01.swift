//
//  X01Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

class X01Game {
    
    let config: Config
    let startingScore: Int
    let targets: [Int: Bool]
    let players: [GamePlayer]
    
    private var _finished: Bool = false
    
    init(config: Config, players: [GamePlayer]) {
        self.config = config
        self.startingScore = config.properties.property(id: "starting_score")?.value as? Int ?? 501
        
        var targets: [Int: Bool] = [:]
        for value in config.targets {
            targets[value] = true
        }
        self.targets = targets
        self.players = players
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        let points = score.sum()
        
        if points == startingScore {
            return .won
        } else if points < startingScore {
            return .ok
        } else {
            return .bust
        }
    }
    
}

extension X01Game: Game {
    
    var rounds: Int? {
        return nil
    }
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
            }
            
            return check(score: player.score())
        }
        return nil
    }
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        score.unHit(target: target)
        
        return check(score: player.score())
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard target.isInPlay(in: self, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func scoreTitle(forPlayer player: GamePlayer, forRound round: Int?) -> String? {
        var bust: Bool = false
        var roundTotal: Int
        if let round = round {
            let score = player.score(for: round)
            bust = score?.bust ?? false
            
            roundTotal = score?.sum() ?? 0
        } else {
            roundTotal = 0
        }
        
        let total = score(forPlayer: player)
        if roundTotal > 0 {
            if bust {
                return "\(total) - \(roundTotal) = \(total - roundTotal)"
            } else {
                return "\(total + roundTotal) - \(roundTotal) = \(total)"
            }
        }
        return "\(total)"
    }
    
    func score(forPlayer player: GamePlayer) -> Int {
        return startingScore - player.score().sum()
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        let scores = players.enumerated().map {
            return (index: $0.offset, score: score(forPlayer: $0.element))
        }
        
        let scoreRank = scores.sorted { (left: (key: Int, value: Int), right: (key: Int, value: Int)) -> Bool in
            return left.value < right.value
        }
        
        return scoreRank.map { players[$0.index] }
    }
    
    func isWinning(player: GamePlayer) -> Bool {
        return score(forPlayer: player) < startingScore && player === rank(players: players).first
    }
    
    func scoreViewController() -> UIViewController? {
        return nil
    }
    
}

fileprivate extension Target {
    
    func isInPlay(in game: X01Game, round: Int) -> Bool {
        return game.targets[value] ?? false
    }
    
}
