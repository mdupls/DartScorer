//
//  Slice.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Tracker {
    
    let value: Int
    
    internal var hits: [Section] = []
    
    init(value: Int) {
        self.value = value
    }
    
    func hit(section: Section) {
        hits.append(section)
    }
    
    var totalValue: Int {
        return totalHits * value
    }
    
    var totalHits: Int {
        return hits.reduce(0) { (result, section) -> Int in
            return result + section.rawValue
        }
    }
    
    func hits(forSection _section: Section) -> Int {
        return hits.reduce(0) { (result, section) -> Int in
            if section == _section {
                return result + 1
            }
            return result
        }
    }
    
    func value(forSection _section: Section) -> Int {
        let hits = self.hits(forSection: _section)
        
        return hits * value * _section.rawValue
    }
    
}

extension Tracker {
    
    func merge(tracker: Tracker) {
        guard value == tracker.value else {
            print("Cannot merge Tracker's for different values")
            return
        }
        
        hits.append(contentsOf: tracker.hits)
    }
    
}
