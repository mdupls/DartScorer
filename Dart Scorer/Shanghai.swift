//
//  Shanghai.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class ShanghaiGame {
    
    let model: BoardModel
    
    private let config: ConfigParser
    
    init(model: BoardModel, config: [String: Any]?) {
        self.model = model
        self.config = ConfigParser(json: config)
    }
    
    // MARK: Private
    
    func check(score: Score) -> ScoreResult {
        return .OK
    }
    
}

extension ShanghaiGame: Game {
    
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
        return players.sorted(by: { (player1, player2) -> Bool in
            return player1.score.sum(model: model) > player2.score.sum(model: model)
        })
    }
    
}

private class ConfigParser {
    
    private let _json: [String: Any]?
    
    init(json: [String: Any]?) {
        self._json = json
    }
    
}
