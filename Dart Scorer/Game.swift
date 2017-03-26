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
    internal var observers: [GameObserver] = []
    
    var rounds: Int {
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
        let round = max(0, min(round, rounds - 1))
        
        // Tell the model to use the enabled targets for the round.
        model.enable(targetsWithValues: config.targetsFor(round: round))
        
        return round
    }
    
    func winner() -> GamePlayer? {
        guard _finished else { return nil }
        
        return game.rank(players: players).first
    }
    
    func won(player: GamePlayer) {
        _finished = true
        
        print("\(player.player.name) won!")
    }
    
    func score(player: GamePlayer, target: Target?, round: Int) {
        var score: Score
        if let _score = player.scores[round] {
            score = _score
        } else {
            score = Score()
            player.scores[round] = score
        }
        
        let result = game.score(player: player, target: target, round: round)
        
        // Notify observers.
        observers.forEach { $0.hit(target: target, player: player) }
        
        switch result {
        case .OK:
            Void()
        case .Bust:
            Void()
        case .Won:
            won(player: player)
        }
    }
    
    func score(forPlayerAt index: Int) -> Score? {
        return players[index].score
    }
    
    func add(observer: GameObserver) {
        observers.append(observer)
    }
    
    func remove(observer: GameObserver) {
        if let index = observers.index(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
}

private class CoreConfig {
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    var rounds: Int {
        return config.rounds
    }
    
    var throwsPerTurn: Int {
        return config.throwsPerTurn
    }
    
    func targetsFor(round: Int) -> [Int] {
        var roundTargets: [Int]?
        if let targets = sequentialTargets, round < targets.count {
            roundTargets = targets[round]
        }
        return roundTargets ?? targets
    }
    
    // MARK: Private
    
    private var sequentialTargets: [[Int]]? {
        return _board?["targets"] as? [[Int]]
    }
    
    private var targets: [Int] {
        return _board?["targets"] as? [Int] ?? []
    }
    
    private var _board: [String : Any]? {
        return config.json?["board"] as? [String : Any]
    }
    
}

protocol Game {
    
    var model: BoardModel { get }
    
    func score(player: GamePlayer, target: Target?, round: Int) -> ScoreResult
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
}

protocol GameObserver: class {
    
    func hit(target: Target?, player: GamePlayer)
    
}
