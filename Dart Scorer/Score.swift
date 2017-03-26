//
//  Tally.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Score {
    
    private var _scores: [Int: Tracker] = [:]
    
    var hits: Int {
        return _scores.reduce(0) { (result, item: (key: Int, value: Tracker)) -> Int in
            return result + item.value.hits
        }
    }
    
    init() {
        
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
        
        score(forTarget: target).hit(section: target.section)
        
        print("--> \(target.value) (x\(target.section.rawValue)) hit for \(target.score) points")
    }
    
    func add(score: Score) {
        score._scores.forEach { key, value in
            _score(forValue: key).merge(tracker: value)
        }
    }
    
    // MARK: Private
    
    private func score(forTarget target: Target) -> Tracker {
        return _score(forValue: target.value)
    }
    
    private func _score(forValue value: Int) -> Tracker {
        if let tracker = _scores[value] {
            return tracker
        }
        
        let tracker = Tracker(value: value)
        _scores[value] = tracker
        return tracker
    }
    
}

extension Score {
        
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
