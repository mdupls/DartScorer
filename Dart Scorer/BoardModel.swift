//
//  BoardModel.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

enum Section: Int {
    case single = 1
    case double = 2
    case triple = 3
}

class BoardModel {
    
    let values: [Int]
    private let slices: [Int]
    
    var sectionCount: Int {
        return _slices.count
    }
    
    private let _bullseye: Target
    private let _doubleBullseye: Target
    private var _slices: [[Section : Target]] = []
    
    init(slices: [Int], bullseye: Int) {
        self.slices = slices
        self.values = [bullseye] + slices
        
        for value in slices {
            var slice: [Section : Target] = [:]
            slice[.single] = Target(value: value, section: .single)
            slice[.double] = Target(value: value, section: .double)
            slice[.triple] = Target(value: value, section: .triple)
            
            _slices.append(slice)
        }
        
        _bullseye = Target(value: bullseye, section: .single)
        _doubleBullseye = Target(value: bullseye, section: .double)
    }
    
    func index(of target: Target) -> Int? {
        if target.score == _bullseye.score {
            return nil
        } else if target.score == _doubleBullseye.score {
            return nil
        }
        
        return slices.index(of: target.value)
    }
    
    func target(forIndex index: Int, section: Section = .single) -> Target? {
        return _slices[index][section]
    }
    
    func target(forValue value: Int, section: Section = .single) -> Target? {
        if let index = slices.index(of: value) {
            return target(forIndex: index, section: section)
        }
        return nil
    }
    
    func targetForBullseye(at section: Section = .single) -> Target? {
        switch section {
        case .single:
            return _bullseye
        case .double:
            return _doubleBullseye
        default:
            return nil
        }
    }
    
}
