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
    
    init(game: Game, model: BoardModel, players: [Player], config: Config) {
        self.game = game
        self.model = model
        self.config = config
        
        self.players = players.map {
            return GamePlayer(player: $0)
        }
    }
    
    func isLast(round: Int) -> Bool {
        if let rounds = rounds {
            return round == rounds - 1
        }
        return false
    }
    
    func winner() -> GamePlayer? {
        guard let player = game.rank(players: players).first else { return nil }
        
        won(player: player)
        
        return player
    }
    
    func won(player: GamePlayer) {
        NotificationCenter.default.post(name: Notification.Name("GameFinished"), object: player, userInfo: nil)
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
            
            // Notify.
            NotificationCenter.default.post(name: Notification.Name("TargetHit"), object: player, userInfo: ["score": score])
            
            switch result {
            case .ok:
                Void()
            case .open:
                NotificationCenter.default.post(name: Notification.Name("TargetOpen"), object: player, userInfo: nil)
            case .close:
                NotificationCenter.default.post(name: Notification.Name("TargetClose"), object: player, userInfo: nil)
            case .bust:
                print("bust")
            case .won:
                won(player: player)
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
            
            // Notify
            NotificationCenter.default.post(name: Notification.Name("TargetUnhit"), object: player, userInfo: [
                "score": score,
                "index": index
                ])
        }
    }
    
    func scoreTitle(forPlayer player: GamePlayer, round: Int) -> String? {
        let totalScore = player.score(at: round)
        let roundScore = player.score(for: round) ?? Score()
        
        return game.score(forPlayer: player, forRound: roundScore, total: totalScore)
    }
    
    func score(forPlayer player: GamePlayer, round: Int? = nil) -> Int? {
        let score = player.score(at: round)
        
        return game.score(forPlayer: player, score: score)
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
    
    func score(forPlayer player: GamePlayer, forRound roundScore: Score, total totalScore: Score) -> String?
    
    func score(forPlayer player: GamePlayer, score: Score) -> Int?
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
    func scoreViewController() -> UIViewController?
    
}
