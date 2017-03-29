//
//  Target.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Target: CustomStringConvertible {
    
    let value: Int
    let section: Section
    
    var score: Int {
        return value * section.rawValue
    }
    
    var description: String {
        return "\(value)x\(section.rawValue)=\(score)"
    }
    
    init(value: Int, section: Section) {
        self.value = value
        self.section = section
    }
    
}

enum TargetState {
    case initial
    case open
    case closed
}
