//
//  X01Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class X01Game {
    
    let model: BoardModel
    let players: [Player]
    let scores: [Score]
    
    var goal: Int = 501
    
    internal var turn: Turn?
    
    private var _currentPlayer: Int = 0
    private var _finished: Bool = false
    
    var currentPlayer: Player {
        return players[_currentPlayer]
    }
    
    init(model: BoardModel, players: [Player]) {
        self.model = model
        self.players = players
        
        var scores: [Score] = []
        for _ in 0 ..< players.count {
            scores.append(Score(values: model.values))
        }
        
        self.scores = scores
    }
    
    // MARK: Private
    
    internal func nextPlayer() {
        _currentPlayer = (_currentPlayer + 1) % players.count
        
        createTurn()
    }
    
    internal func createTurn() {
        turn = Turn(player: currentPlayer, score: Score(values: model.values), turns: 3)
        
        print("\(currentPlayer.name)'s turn")
    }
    
    internal func getScore(player: Player) -> Score? {
        if let index = players.index(where: { (p) -> Bool in
            return p.name == player.name
        }) {
            return scores[index]
        }
        
        return nil
    }
    
    internal func checkScore(score: Score, turn: Turn) -> ScoreResult {
        let points = score.sum() + turn.score.sum()
        
        if points == goal {
            return .Won
        } else if points < goal {
            return .OK
        } else {
            return .Bust
        }
    }
    
    internal func won(player: Player) {
        _finished = true
        
        print("\(player.name) won!")
    }
    
}

extension X01Game: Game {
    
    func start() {
        createTurn()
    }
    
    func score(player: Player, target: Target?) {
        guard let turn = turn else { return }
        guard let score = getScore(player: player) else { return }
        
        turn.hit(target: target)
        
        let result = checkScore(score: score, turn: turn)
        
        switch result {
        case .OK:
            print("\(player.name)'s score: \(score.sum() + turn.score.sum())")
            
            if turn.done {
                score.add(score: turn.score)
                
                nextPlayer()
            }
        case .Bust:
            print("\(player.name) bust! Score: \(score.sum())")
            nextPlayer()
        case .Won:
            score.add(score: turn.score)
            print("\(player.name)'s score: \(score.sum())")
            
            won(player: player)
        }
    }
    
}

extension X01Game: MarkerViewDataSource {
    
    func numberOfSections(in markerView: MarkerView) -> Int {
        return model.sectionCount
    }
    
    func markerView(_ markerView: MarkerView, hitsFor value: Int) -> Int {
        return 1
    }
    
}

enum ScoreResult {
    case OK
    case Bust
    case Won
}

private let slices = [25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]

internal extension Score {
    
    func sum() -> Int {
        var sum = 0
        for value in score(forValues: slices) {
            sum += value.value.totalValue
        }
        return sum
//        return score(forValues: slices).reduce(0, { (result, item: (key, value)) -> Result in
//            result = item.va
//        })
    }
    
}
