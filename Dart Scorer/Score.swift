//
//  Tally.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Score {
    
    private var _values: [Int]
    private var _scores: [Int: Tracker] = [:]
    
    init(values: [Int]) {
        _values = values
        
        for value in values {
            _scores[value] = Tracker(value: value)
        }
    }
    
    func score(forValue value: Int) -> Tracker? {
        return _scores[value]
    }
    
    func score(forValues values: [Int]) -> [Tracker] {
        var scores: [Tracker] = []
        
        for value in values {
            if let tracker = score(forValue: value) {
                scores.append(tracker)
            }
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
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Score(values: _values)
    }
    
}

extension Score {
    
    static func + (left: Score, right: Score) -> Score {
        let score = left.copy() as! Score
        score.add(score: right)
        return score
    }
        
    func sum(model: BoardModel) -> Int {
        return score(forValues: model.values).reduce(0, { (result, tracker) -> Int in
            return result + tracker.totalValue
        })
    }
    
}

enum ScoreResult {
    case OK
    case Bust
    case Won
}
