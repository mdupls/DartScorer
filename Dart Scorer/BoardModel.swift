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
    
    private let indexMap: [Int] = [
        // Numbers for each section in the range [0, 2*PI)
        20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5
    ]
    
    var sectionCount: Int {
        return indexMap.count
    }
    
    private var _bullseye: Target = Target(value: 25, section: .Single)
    private var _doubleBullseye: Target = Target(value: 25, section: .Double)
    private var _slices: [[Section : Target]] = []
    
    init() {
        for value in indexMap {
            var slice: [Section : Target] = [:]
            slice[.Single] = Target(value: value, section: .Single)
            slice[.Double] = Target(value: value, section: .Double)
            slice[.Triple] = Target(value: value, section: .Triple)
            
            _slices.append(slice)
        }
    }
    
    var sweepAngle: CGFloat {
        return (CGFloat.pi * 2) / CGFloat(sectionCount)
    }
    
    func angle(forIndex index: Int) -> CGFloat {
        let startAngle = (CGFloat.pi / 2) * 3 - sweepAngle / 2
        
        return (startAngle + (CGFloat(index) * sweepAngle)).truncatingRemainder(dividingBy: CGFloat.pi * 2)
    }
    
    func slice(forAngle angle: CGFloat, radius: CGFloat) -> Target? {
        let normalizedAngle = angle < 0 ? angle + CGFloat.pi : angle - CGFloat.pi
        
        var index = Int(ceil(abs(normalizedAngle) / (sweepAngle / 2)) / 2.0)
        
        if angle < 0 {
            index = sectionCount - index
            if index >= sectionCount {
                index -= sectionCount
            }
        }
        
        return slice(forIndex: index)
    }
    
    func slice(forIndex index: Int, section: Section = .Single) -> Target? {
        return _slices[index][section]
    }
    
    func slice(forValue value: Int, section: Section = .Single) -> Target? {
        if let index = indexMap.index(of: value) {
            return slice(forIndex: index, section: section)
        }
        return nil
    }
    
    func bullseye(section: Section = .Single) -> Target? {
        switch section {
        case .Single:
            return _bullseye
        case .Double:
            return _doubleBullseye
        default:
            return nil
        }
    }
    
}
