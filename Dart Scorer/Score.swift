//
//  Tally.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Score {
    
    internal var _scores: [Int: Tracker] = [:]
    
    init(values: [Int]) {
        for value in values {
            _scores[value] = Tracker(value: value)
        }
    }
    
    func score(forValues values: [Int]) -> [Int: Tracker] {
        var scores: [Int: Tracker] = [:]
        
        for value in values {
            scores[value] = _scores[value]
        }
        
        return scores
    }
    
    func hit(target: Target) {
        guard target.enabled else {
            print("--> Missed on \(target.value) (x\(target.section.rawValue)) for 0 points")
            return
        }
        
        _scores[target.value]?.hit(section: target.section)
        
        print("--> \(target.value) (x\(target.section.rawValue)) hit for \(target.score) points")
    }
    
    func add(score: Score) {
        score._scores.forEach { key, value in
            _scores[key]?.merge(tracker: value)
        }
    }
    
}
