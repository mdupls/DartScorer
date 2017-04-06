//
//  AroundTheWorldGame.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-04.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class AroundTheWorldGame {
    
    let config: Config
    let targets: [Int]
    
    // Mapping of player names to current index in the array of targets.
    private var playerCursor: [String : Int] = [:]
    // Mapping of target values to players
    private var playerMap: [Int: GamePlayer] = [:]
    
    init(config: Config) {
        self.config = config
        self.targets = config.targets
    }
    
    func isInPlay(target: Target, player: GamePlayer) -> Bool {
        guard let value = self.target(forPlayer: player) else { return false }
        
        return target.value == value
    }
    
    func hit(target: Target, player: GamePlayer) {
        let index = playerCursor[player.name] ?? 0
        
        playerCursor[player.name] = index + 1
    }
    
    func unHit(target: Target, player: GamePlayer) {
        let index = playerCursor[player.name] ?? 0
        
        playerCursor[player.name] = max(0, index - 1)
    }
    
    func hasWon(player: GamePlayer) -> Bool {
        let index = playerCursor[player.name] ?? 0
        
        return index >= targets.count
    }
    
    func target(forPlayer player: GamePlayer) -> Int? {
        let index = playerCursor[player.name] ?? 0
        
        return target(forIndex: index)
    }
    
    // MARK: Private
    
    private func target(forIndex index: Int) -> Int? {
        guard index < targets.count && index >= 0 else { return nil }
        
        return targets[index]
    }
    
}

extension AroundTheWorldGame: Game {
    
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
    
    func score(forPlayer player: GamePlayer, forRound roundScore: Score, total totalScore: Score) -> String? {
        if let score = score(forPlayer: player) {
            return "Target: \(score)"
        }
        return nil
    }
    
    func score(forPlayer player: GamePlayer) -> Int? {
        if hasWon(player: player) {
            return targets.last
        }
        
        return target(forPlayer: player)
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players.sorted(by: { (player1, player2) -> Bool in
            return player1.score().sum() > player2.score().sum()
        })
    }
    
}
