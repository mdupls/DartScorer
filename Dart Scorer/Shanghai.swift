//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

class ShanghaiGame {
    
    fileprivate let config: Config
    private let targets: [Int]
    private let startingIndex: Int
    private let endingIndex: Int
    private let clockwise: Bool
    fileprivate let _rounds: Int
    let players: [GamePlayer]
    
    init(config: Config, players: [GamePlayer]) {
        self.config = config
        self.targets = config.targets
        self.players = players
        
        let startingTarget = config.properties.property(id: "starting_target")?.value as? Int ?? 1
        let endingTarget = config.properties.property(id: "ending_target")?.value as? Int ?? 25
        
        startingIndex = targets.index(of: startingTarget) ?? 0
        endingIndex = targets.index(of: endingTarget) ?? max(0, config.targets.count - 1)
        
        clockwise = startingIndex <= endingIndex
        _rounds = abs(endingIndex - startingIndex) + 1
    }
    
    func isInPlay(target: Target, player: GamePlayer, round: Int) -> Bool {
        return target.value == self.target(forRound: round)
    }
    
    func hasWon(game: CoreGame, player: GamePlayer, round: Int) -> ScoreResult? {
        let players = rank(players: game.players)
        
        let remainingPointsPossible = self.remainingPointsPossible(from: round)
        
        if players.count == 1 {
            if round == _rounds - 1 {
                return .won
            }
        } else {
            if players[0].score().sum() > players[1].score().sum() + remainingPointsPossible {
                return .won
            }
        }
        
        return .ok
    }
    
    // MARK: Private
    
    private func target(forRound round: Int) -> Int {
        if clockwise {
            return targets[min(endingIndex, max(startingIndex, startingIndex + round))]
        } else {
            return targets[min(startingIndex, max(endingIndex, startingIndex - round))]
        }
    }
    
    private func remainingPointsPossible(from round: Int) -> Int {
        var sum = 0
        let start = clockwise ? startingIndex + round : endingIndex - round
        let end = clockwise ? endingIndex : startingIndex
        
        for r in start ... end {
            let target = targets[r]
            
            let maxMultiplier = config.isBullseye(value: target) ? Section.double.rawValue : Section.triple.rawValue
            
            sum += target * maxMultiplier * config.throwsPerTurn
        }
        
        return sum
    }
    
}

extension ShanghaiGame: Game {
    
    var rounds: Int? {
        return _rounds
    }
    
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
        guard isInPlay(target: target, player: player, round: round) else {
            return .closed
        }
        
        return .initial
    }
    
    func scoreTitle(forPlayer player: GamePlayer, forRound round: Int?) -> String? {
        var roundTotal: Int
        if let round = round {
            roundTotal = player.score(for: round)?.sum() ?? 0
        } else {
            roundTotal = 0
        }
        let total = player.score().sum()
        
        if roundTotal > 0 {
            return "\(total - roundTotal) + \(roundTotal) = \(total)"
        }
        return "\(total)"
    }
    
    func score(forPlayer player: GamePlayer) -> Int {
        return player.score().sum()
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        let scores = players.enumerated().map {
            return (index: $0.offset, score: score(forPlayer: $0.element))
        }
        
        let scoreRank = scores.sorted { (left: (key: Int, value: Int), right: (key: Int, value: Int)) -> Bool in
            return left.value > right.value
        }
        
        return scoreRank.map { players[$0.index] }
    }
    
    func isWinning(player: GamePlayer) -> Bool {
        return score(forPlayer: player) > 0 && player === rank(players: players).first
    }
    
    func scoreViewController() -> UIViewController? {
        return nil
    }
    
}
