//
//  Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

enum GameState {
    case finished
    case inProgress
    case lastRound
}

class CoreGame {
    
    let game: Game
    let model: BoardModel
    let players: [GamePlayer]
    
    private let config: Config
    
    private var _winner: (player: GamePlayer, round: Int)?
    
    var winner: (player: GamePlayer, round: Int)? {
        return _winner
    }
    
    var leader: GamePlayer? {
        let leader = game.rank(players: players).first
        if (leader?.totalHits ?? 0) > 0 {
            return leader
        }
        return nil
    }
    
    var throwsPerTurn: Int {
        return config.throwsPerTurn
    }
    
    var rounds: Int? {
        return game.rounds
    }
    
    var name: String {
        return config.name
    }
    
    var showHitMarkers: Bool {
        return config.showHitMarkers
    }
    
    var targetHitsRequired: Int? {
        return config.targetHitsRequired
    }
    
    var showMultipliers: Bool {
        return config.showMultipliers
    }
    
    init(game: Game, model: BoardModel, players: [GamePlayer], config: Config) {
        self.game = game
        self.model = model
        self.players = players
        self.config = config
    }
    
    func isLast(round: Int) -> Bool {
        if let rounds = rounds {
            return round == rounds - 1
        }
        return false
    }
    
    func isWinning(player: GamePlayer) -> Bool {
        return game.isWinning(player: player)
    }
    
    func rankedPlayers() -> [GamePlayer] {
        return game.rank(players: players)
    }
    
    func won(player: GamePlayer, round: Int) {
        _winner = (player: player, round: round)
    }
    
    func score(player: GamePlayer, target: Target, round: Int) {
        var score: Score
        if let _score = player.scores[round] {
            guard !_score.bust else { return }
            
            score = _score
        } else {
            score = Score()
            player.scores[round] = score
        }
        
        if let result = game.game(self, hit: target, player: player, round: round) {
            if result == .bust {
                score.bust = true
            }
            
            if result == .won {
                won(player: player, round: round)
            }
            
            // Notify.
            NotificationCenter.default.post(name: Notification.Name("TargetHit"), object: player, userInfo: ["score": score])
            
            if result == .open {
                NotificationCenter.default.post(name: Notification.Name("TargetOpen"), object: player, userInfo: nil)
            } else if result == .close {
                NotificationCenter.default.post(name: Notification.Name("TargetClose"), object: player, userInfo: nil)
            }
        }
    }
    
    func undoScore(player: GamePlayer, target index: Int, round: Int) {
        guard let score = player.scores[round] else { return }
        
        let target = score.targets[index]
        
        if let result = game.game(self, undoHit: target, player: player, round: round) {
            if result != .bust {
                score.bust = false
            }
            
            if result != .won && player === _winner?.player {
                // The player is not the winner anymore since they removed a score and the result is not 'won'.
                _winner = nil
            }
            
            // Notify
            NotificationCenter.default.post(name: Notification.Name("TargetUnhit"), object: player, userInfo: [
                "score": score,
                "index": index
                ])
        }
    }
    
    func scoreTitle(player: GamePlayer, round: Int? = nil) -> String? {
        return game.scoreTitle(forPlayer: player, forRound: round)
    }
    
    func score(forPlayer player: GamePlayer) -> Int? {
        return game.score(forPlayer: player)
    }
    
    func state(for targetValue: Int, player: GamePlayer, round: Int) -> TargetState {
        if let target = model.target(forValue: targetValue) {
            return game.game(self, stateFor: target, player: player, round: round)
        }
        return .closed
    }
    
}

protocol Game {
    
    var rounds: Int? { get }
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult?
    
    func game(_ game: CoreGame, undoHit target: Target, player: GamePlayer, round: Int) -> ScoreResult?
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState
    
    func scoreTitle(forPlayer player: GamePlayer, forRound round: Int?) -> String?
    
    func score(forPlayer player: GamePlayer) -> Int
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
    func isWinning(player: GamePlayer) -> Bool
    
    func scoreViewController() -> UIViewController?
    
}
