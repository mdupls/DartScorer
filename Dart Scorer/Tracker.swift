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
    
    internal var _hits: [Section] = []
    
    init(value: Int) {
        self.value = value
    }
    
    func hit(section: Section) {
        _hits.append(section)
        
        print("\(value) has \(_hits.count) hits")
    }
    
    /// - returns: The total value of all hits of this value
    var totalValue: Int {
        return totalHits * value
    }
    
    /// - returns: The number of times this value has been hit (ie. hit(section:) calls)
    var totalHits: Int {
        return _hits.reduce(0) { (result, section) -> Int in
            return result + section.rawValue
        }
    }
    
    var hits: Int {
        return _hits.count
    }
    
    func hits(forSection _section: Section) -> Int {
        return _hits.reduce(0) { (result, section) -> Int in
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
        
        _hits.append(contentsOf: tracker._hits)
    }
    
}
