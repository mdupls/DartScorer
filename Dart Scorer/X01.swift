//
//  X01Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class X01Game {
    
    let players: [Player]
    let scores: [Score]
    
    var goal: Int = 501
    
    internal var turn: X01Turn?
    
    private var _currentPlayer: Int = 0
    private var _finished: Bool = false
    
    var stats: Stats {
        let rank = rankPlayers()
        
        return Stats(rank: rank)
    }
    
    var currentPlayer: Player {
        return players[_currentPlayer]
    }
    
    init(players: [Player]) {
        self.players = players
        
        var scores: [Score] = []
        for _ in 0 ..< players.count {
            scores.append(Score())
        }
        
        self.scores = scores
    }
    
    // MARK: Private
    
    internal func rankPlayers() ->  {
        
    }
    
    internal func nextPlayer() {
        _currentPlayer = (_currentPlayer + 1) % players.count
        
        newTurn()
    }
    
    internal func newTurn() {
        turn = X01Turn(player: currentPlayer)
    }
    
    internal func getScore(player: Player) -> Score? {
        if let index = players.index(where: { (p) -> Bool in
            return p.name == player.name
        }) {
            return scores[index]
        }
        
        return nil
    }
    
    internal func checkScore(score: Score, turn: X01Turn) -> ScoreResult {
        let possibleScore = score.score + turn.score
        
        if possibleScore < goal {
            return .OK
        } else if possibleScore == goal {
            return .Won
        } else {
            return .Bust
        }
    }
    
    internal func won(player: Player) {
        _finished = true
    }
    
}

extension X01Game: IGame {
    
    func start() {
        newTurn()
    }
    
    func score(player: Player, target: Target?) {
        guard let turn = turn else { return }
        guard let score = getScore(player: player) else { return }
        
        let controller = TurnController(turn: turn, turns: 3)
        let points = controller.score(target: target)
        
        print("\(player.name) scored \(points) points.")
        print("\(player)")
        
        let result = checkScore(score: score, turn: turn)
        
        switch result {
        case .OK:
            score.score(turn: turn)
            nextPlayer()
        case .Bust:
            nextPlayer()
        case .Won:
            score.score(turn: turn)
            won(player: player)
        }
    }
    
}

enum ScoreResult {
    case OK
    case Bust
    case Won
}

internal class X01Turn {
    
    private let player: Player
    private var _score: Int = 0
    
    var score: Int { return _score }
    
    init(player: Player) {
        self.player = player
    }
    
    func score(points: Int) -> Int {
        _score += points
        
        return points
    }
    
}

extension X01Turn: Turn {
    
    func score(target: Target?) -> Int {
        let points = target?.score ?? 0
        
        return score(points: points)
    }
    
}

class X01Score {
    
    private var _score: Int = 0
    
    var score: Int {
        return _score
    }
    
    init() {
        
    }
    
    func score(targets: [Target]) {
        
    }
    
    func score(points: Int) {
        _score += points
        
        print("\(_score)")
    }
    
}

extension X01Score: Score {
    
    func score(targets: [Target]) {
        
    }
    
}

extension Score {
    
    func score(turn: X01Turn) {
        score(points: turn.score)
    }
    
}
