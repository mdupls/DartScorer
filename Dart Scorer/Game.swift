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
        
        // Tell the model to use the enabled targets for the round.
//        model.enable(targetsWithValues: game.targets(for: boundedRound))
        
        // Notify of round change.
        NotificationCenter.default.post(name: Notification.Name("RoundChange"), object: self, userInfo: nil)
        
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
    
    func score(player: GamePlayer, target: Target?, round: Int) {
        guard !_finished else { return }
        
        var score: Score
        if let _score = player.scores[round] {
            score = _score
        } else {
            score = Score()
            player.scores[round] = score
        }
        
        let result = game.game(self, hit: target, player: player, round: round)
        
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
    
    func score(forPlayerAt index: Int) -> Score? {
        return players[index].score
    }
    
}

private class CoreConfig {
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    var rounds: Int? {
        return config.rounds
    }
    
    var throwsPerTurn: Int {
        return config.throwsPerTurn
    }
    
    // MARK: Private
    
    private var _board: [String : Any]? {
        return config.json?["board"] as? [String : Any]
    }
    
}

protocol Game {
    
    func game(_ game: CoreGame, hit target: Target?, player: GamePlayer, round: Int) -> ScoreResult
    
    func game(_ game: CoreGame, stateFor target: Target, player: GamePlayer, round: Int) -> TargetState
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
}
