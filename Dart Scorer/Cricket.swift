//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class CricketGame {
    
    let model: BoardModel
    var goal: Int = 501
    
    private let config: ConfigParser
    
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

extension CricketGame: Game {
    
    func score(accumulation score: Score, turn: Turn, target: Target?) -> (score: Score, result: ScoreResult) {
        turn.hit(target: target)
        
        var resultScore: Score
        
        if turn.done {
            score.add(score: turn.score)
            resultScore = score
        } else {
            resultScore = score + turn.score
        }
        
        print("\(turn.player.name)'s score: \(resultScore.sum(model: model))")
        
        return (score: resultScore, result: check(score: resultScore))
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
