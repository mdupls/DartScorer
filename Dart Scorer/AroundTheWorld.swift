//
//  AroundTheWorldGame.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-04.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

class AroundTheWorldGame {
    
    let config: Config
    let targets: [Int]
    let startingIndex: Int
    let endingIndex: Int
    let clockwise: Bool
    let players: [GamePlayer]
    
    // Mapping of player names to current index in the array of targets.
    private var playerCursor: [String : Int] = [:]
    // Mapping of target values to players
    private var playerMap: [Int: GamePlayer] = [:]
    
    init(config: Config, players: [GamePlayer]) {
        self.config = config
        self.targets = config.targets
        self.players = players
        
        let startingTarget = config.properties.property(id: "starting_target")?.value as? Int ?? 1
        let endingTarget = config.properties.property(id: "ending_target")?.value as? Int ?? 25
        
        startingIndex = targets.index(of: startingTarget) ?? 0
        endingIndex = targets.index(of: endingTarget) ?? max(0, config.targets.count - 1)
        
        clockwise = startingIndex <= endingIndex
    }
    
    func isInPlay(target: Target, player: GamePlayer) -> Bool {
        return target.value == self.target(forPlayer: player)
    }
    
    func hit(target: Target, player: GamePlayer) {
        let index = self.index(forPlayer: player)
        
        if clockwise {
            playerCursor[player.name] = index + 1
        } else {
            playerCursor[player.name] = index - 1
        }
    }
    
    func unHit(target: Target, player: GamePlayer) {
        let index = self.index(forPlayer: player)
        
        if clockwise {
            playerCursor[player.name] = max(startingIndex, index - 1)
        } else {
            playerCursor[player.name] = min(startingIndex, index + 1)
        }
    }
    
    func hasWon(player: GamePlayer) -> Bool {
        let index = self.index(forPlayer: player)
        
        if clockwise {
            return index > endingIndex
        } else {
            return index < endingIndex
        }
    }
    
    func target(forPlayer player: GamePlayer) -> Int {
        let index = self.index(forPlayer: player)
        
        if clockwise {
            return targets[min(endingIndex, max(startingIndex, index))]
        } else {
            return targets[min(startingIndex, max(endingIndex, index))]
        }
    }
    
    // MARK: Private
    
    private func index(forPlayer player: GamePlayer) -> Int {
        return playerCursor[player.name] ?? startingIndex
    }
    
}

extension AroundTheWorldGame: Game {
    
    var rounds: Int? {
        return nil
    }
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        if score.hits < config.throwsPerTurn {
            let state = self.game(game, stateFor: target, player: player, round: round)
            
            if state != .closed {
                score.hit(target: target)
                hit(target: target, player: player)
                
                // If the player hit the target and this is the last target, they win.
                if hasWon(player: player) {
                    return .won
                }
            }
            return .ok
        }
        return nil
    }
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult? {
        let score = player.scores[round]!
        
        score.unHit(target: target)
        unHit(target: target, player: player)
        
        return .ok
    }
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState {
        guard isInPlay(target: target, player: player) else {
            return .closed
        }
        
        return .initial
    }
    
    func scoreTitle(forPlayer player: GamePlayer, forRound round: Int?) -> String? {
        return "Target: \(target(forPlayer: player))"
    }
    
    func score(forPlayer player: GamePlayer, forRound round: Int? = nil) -> Int {
        return target(forPlayer: player)
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        let scores = players.enumerated().map {
            return (index: $0.offset, score: score(forPlayer: $0.element))
        }
        
        let scoreRank = scores.sorted { (left: (key: Int, value: Int), right: (key: Int, value: Int)) -> Bool in
            if clockwise {
                return left.value > right.value
            } else {
                return left.value < right.value
            }
        }
        
        return scoreRank.map { players[$0.index] }
    }
    
    func isWinning(player: GamePlayer) -> Bool {
        if clockwise {
            guard score(forPlayer: player) > startingIndex + 1 else {
                return false
            }
        } else {
            guard score(forPlayer: player) < startingIndex + 1 else {
                return false
            }
        }
        return player === rank(players: players).first
    }
    
    func scoreViewController() -> UIViewController? {
        return nil
    }
    
}
