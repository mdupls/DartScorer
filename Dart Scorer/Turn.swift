//
//  Turn.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Turn {
    
    let score: Score
    let player: Player
    let turns: Int
    
    private var _turnsTaken: Int = 0
    
    var done: Bool { return _turnsTaken >= turns }
    
    init(player: Player, score: Score, turns: Int) {
        self.player = player
        self.score = score
        self.turns = turns
    }
    
    func hit(target: Target?) {
        guard !done else { return }
        
        _turnsTaken += 1
        
        if let target = target {
            score.hit(target: target)
        }
    }
    
}
