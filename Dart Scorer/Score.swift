//
//  Tally.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Score {
    
    var targets: [Target] = []
    var bust: Bool = false
    
    var hits: Int {
        return targets.count
    }
    
    init() {
        
    }
    
    func hit(target: Target) {
        targets.append(target)
        
        print("--> \(target.value) (x\(target.section.rawValue)) hit for \(target.score) points")
    }
    
    func unHit(target: Target) {
        let score = target.score
        
        if let index = targets.index(where: { (_target) -> Bool in
            return _target.score == score
        }) {
            targets.remove(at: index)
        }
    }
    
    func totalHits(for value: Int? = nil) -> Int {
        return targets.reduce(0) { (result, target) -> Int in
            if value == nil || target.value == value {
                return result + target.section.rawValue
            }
            return result
        }
    }
    
    func add(score: Score) {
        targets.append(contentsOf: score.targets)
    }
    
    func removeTarget(at index: Int) {
        targets.remove(at: index)
    }
    
}

extension Score {
        
    func sum() -> Int {
        return targets.reduce(0, { (result, target) -> Int in
            return result + target.score
        })
    }
    
}

enum ScoreResult {
    case ok
    case open
    case close
    case bust
    case won
}
