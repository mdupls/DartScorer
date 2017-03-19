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
    
    private let config: ConfigParser
    
    private var _round: Int = 0
    private var _finished: Bool = false
    
    internal var _currentPlayer: Int = 0
    internal var turn: Turn?
    internal var observers: [GameObserver] = []
    
    var round: Int {
        return _round
    }
    
    var rounds: Int {
        return config.rounds
    }
    
    var currentPlayer: GamePlayer {
        return players[_currentPlayer]
    }
    
    init(game: Game, model: BoardModel, players: [Player], config: [String: Any]?) {
        self.game = game
        self.model = model
        self.config = ConfigParser(json: config)
        
        var gamePlayers: [GamePlayer] = []
        for player in players {
            gamePlayers.append(GamePlayer(player: player, score: Score(values: model.values)))
        }
        self.players = gamePlayers
        
        createTurn()
    }
    
    func createTurn() {
        turn = Turn(player: GamePlayer(player: currentPlayer.player, score: Score(values: model.values)), turns: 3)
        
        print("\(currentPlayer.player.name)'s turn")
    }
    
    func nextRound() -> Bool {
        if _round < rounds - 1 {
            _round += 1
            
            // Player 1 is up.
            _currentPlayer = 0
            
            model.enable(targetsWithValues: config.targetsFor(round: round))
            
            // Notify observers.
            observers.forEach { $0.nextRound() }
            return true
        } else {
            _finished = true
        }
        return false
    }
    
    func nextPlayer() -> Bool {
        if _currentPlayer < players.count - 1 {
            _currentPlayer += 1
            
            // Create a new turn.
            createTurn()
            return true
        }
        return false
    }
    
    func winner() -> GamePlayer? {
        guard _finished else { return nil }
        
        return game.rank(players: players).first
    }
    
    func won(player: GamePlayer) {
        _finished = true
        
        print("\(player.player.name) won!")
    }
    
    func score(target: Target?) {
        guard !_finished else { return }
        guard let turn = turn, !turn.done else { return }
        
        let ret = game.score(accumulation: currentPlayer.score, turn: turn, target: target)
        
        // Notify observers.
        observers.forEach { $0.hit(target: target, score: ret.score) }
        
        switch ret.result {
        case .OK:
            Void()
        case .Bust:
            Void()
        case .Won:
            won(player: turn.player)
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

private class ConfigParser {
    
    private let _json: [String: Any]?
    
    init(json: [String: Any]?) {
        self._json = json
    }
    
    var rounds: Int {
        return sequentialTargets?.count ?? 0
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
        return _json?["board"] as? [String : Any]
    }
    
}

protocol Game {
    
    var model: BoardModel { get }
    
    func score(accumulation score: Score, turn: Turn, target: Target?) -> (score: Score, result: ScoreResult)
    
    func rank(players: [GamePlayer]) -> [GamePlayer]
    
}

protocol GameObserver: class {
    
    func hit(target: Target?, score: Score)
    
    func nextRound()
    
}
