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
    let goal: Int
    let targets: [Int: Bool]
    
    private var _finished: Bool = false
    
    init(config: Config, players: [GamePlayer]) {
        self.config = config
        self.goal = config.properties.property(id: "starting_score")?.value as? Int ?? 501
        
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
        var roundTotal: Int
        if let round = round {
            roundTotal = player.score(for: round)?.sum() ?? 0
        } else {
            roundTotal = 0
        }
        
        let total = score(forPlayer: player)
        if roundTotal > 0 {
            return "\((total + roundTotal)) - \(roundTotal) = \(total)"
        }
        return "\(total)"
    }
    
    func score(forPlayer player: GamePlayer, forRound round: Int? = nil) -> Int {
        return goal - player.score().sum()
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
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
