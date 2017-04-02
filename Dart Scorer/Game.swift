//
//  Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class CoreGame {
    
    let game: Game
    let model: BoardModel
    let players: [GamePlayer]
    let throwsPerTurn: Int = 3
    
    private let config: CoreConfig
    
    private var _finished: Bool = false
    
    var rounds: Int? {
        return config.rounds
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
        self.config = CoreConfig(config: config)
        
        self.players = players.map {
            return GamePlayer(player: $0)
        }
    }
    
    func select(round: Int) -> Int {
        var boundedRound = max(0, round)
        
        if let rounds = rounds {
            boundedRound = min(boundedRound, rounds - 1)
        }
        
        // Notify of round change.
        NotificationCenter.default.post(name: Notification.Name("RoundChange"), object: self, userInfo: ["round": boundedRound])
        
        return boundedRound
    }
    
    func winner() -> GamePlayer? {
        guard _finished else { return nil }
        
        return game.rank(players: players).first
    }
    
    func won(player: GamePlayer) {
        _finished = true
        
        print("\(player.player.name) won!")
        
        NotificationCenter.default.post(name: Notification.Name("GameFinished"), object: player, userInfo: nil)
    }
    
    func score(player: GamePlayer, target: Target, round: Int) {
        guard !_finished else { return }
        
        var score: Score
        if let _score = player.scores[round] {
            score = _score
        } else {
            score = Score()
            player.scores[round] = score
        }
        
        if let result = game.game(self, hit: target, player: player, round: round) {
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
                player.scores.removeValue(forKey: round)
            case .won:
                won(player: player)
            }
        }
    }
    
    func undoScore(player: GamePlayer, target index: Int, round: Int) {
        guard let score = player.scores[round] else { return }
        
        score.removeTarget(at: index)
        
        // Notify
        NotificationCenter.default.post(name: Notification.Name("TargetUnhit"), object: player, userInfo: [
            "score": score,
            "index": index
        ])
        
        _finished = false
    }
    
    func score(forPlayerAt index: Int) -> Score? {
        return players[index].score
    }
    
    func score(for player: GamePlayer, round: Int) -> String {
        let totalScore = player.score
        let roundScore = player.score(for: round) ?? Score()
        
        return game.score(forRound: roundScore, total: totalScore)
    }
    
}

private class CoreConfig {
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    var name: String {
        return config.name
    }
    
    var rounds: Int? {
        return config.rounds
    }
    
    var throwsPerTurn: Int {
        return config.throwsPerTurn
    }
    
    var showHitMarkers: Bool {
        return config.showHitMarkers
    }
    
    var targetHitsRequired: Int? {
        return config.targetHitsRequired
    }
    
    // MARK: Private
    
    private var _board: [String : Any]? {
        return config.json?["board"] as? [String : Any]
    }
    
}

protocol Game {
    
    func game(_ game: CoreGame, hit target: Target, player: GamePlayer, round: Int) -> ScoreResult?
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState
    
    func score(forRound roundScore: Score, total totalScore: Score) -> String
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
}
