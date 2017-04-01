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
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
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
