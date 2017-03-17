//
//  Stats.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Stats {
    
    let rank: [Player]
//    let scores: [Score]
    
    init(rank: [Player]/*, scores: [Score]*/) {
        self.rank = rank
//        self.scores = scores
    }
    
    var winner: Player { return rank[0] }
    
//    func score(forPlayer: Player) -> Score {
//        
//    }
    
//    func scores() -> [(player: Player, score: Score)] {
//        var scores: [(player: Player, score: Score)] = []
//        
//        for player in rank {
//            
//        }
//        
//        return scores
//    }
    
}
