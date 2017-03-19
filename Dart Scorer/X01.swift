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
    
    var goal: Int = 501
    
    private let config: ConfigParser
    private var _finished: Bool = false
    
    init(model: BoardModel, config: [String: Any]?) {
        self.model = model
        self.config = ConfigParser(json: config)
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        let points = score.sum(model: model)
        
        if points == goal {
            return .Won
        } else if points < goal {
            return .OK
        } else {
            return .Bust
        }
    }
    
}

extension X01Game: Game {
    
    func score(accumulation score: Score, turn: Turn, target: Target?) -> (score: Score, result: ScoreResult) {
        turn.hit(target: target)
        
        let possibleScore = score + turn.score
        let result = check(score: possibleScore)
        var resultScore: Score
        
        switch result {
        case .OK:
            if turn.done {
                score.add(score: turn.score)
                resultScore = score
            } else {
                resultScore = possibleScore
            }
        case .Bust:
            resultScore = score
        case .Won:
            score.add(score: turn.score)
            resultScore = score
        }
        
        print("\(turn.player.name)'s score: \(resultScore.sum(model: model))")
        
        return (score: resultScore, result: result)
    }
    
    func rank(players: [GamePlayer]) -> [GamePlayer] {
        return players
    }
    
}

private class ConfigParser {
    
    private let _json: [String: Any]?
    
    init(json: [String: Any]?) {
        self._json = json
    }
    
}
