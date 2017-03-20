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
    case Single = 1
    case Double = 2
    case Triple = 3
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
            slice[.Single] = Target(value: value, section: .Single)
            slice[.Double] = Target(value: value, section: .Double)
            slice[.Triple] = Target(value: value, section: .Triple)
            
            _slices.append(slice)
        }
        
        _bullseye = Target(value: bullseye, section: .Single)
        _doubleBullseye = Target(value: bullseye, section: .Double)
    }
    
    func target(forIndex index: Int, section: Section = .Single) -> Target? {
        return _slices[index][section]
    }
    
    func target(forValue value: Int, section: Section = .Single) -> Target? {
        if let index = slices.index(of: value) {
            return target(forIndex: index, section: section)
        }
        return nil
    }
    
    func targetForBullseye(at section: Section = .Single) -> Target? {
        switch section {
        case .Single:
            return _bullseye
        case .Double:
            return _doubleBullseye
        default:
            return nil
        }
    }
    
    func enable(targetsWithValues values: [Int]) {
        _slices.forEach { (value: [Section : Target]) in
            value.forEach {
                $1.enabled = false
            }
        }
        
        for value in values {
            target(forValue: value, section: .Single)?.enabled = true
            target(forValue: value, section: .Double)?.enabled = true
            target(forValue: value, section: .Triple)?.enabled = true
        }
    }
    
}

extension BoardModel: BoardViewDataSource {
    
    func numberOfSections(in boardView: BoardView) -> Int {
        return sectionCount
    }
    
    func boardView(_ boardView: BoardView, targetAt index: Int, for section: Section) -> Target? {
        return target(forIndex: index, section: section)
    }
    
    func boardView(_ boardView: BoardView, bullsEyeTargetFor section: Section) -> Target? {
        return targetForBullseye(at: section)
    }
    
}
