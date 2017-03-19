//
//  Turn.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Turn {
    
    let player: GamePlayer
    let turns: Int
    
    private var _turnsTaken: Int = 0
    
    var done: Bool { return _turnsTaken >= turns }
    var score: Score { return player.score }
    
    init(player: GamePlayer, turns: Int) {
        self.player = player
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
