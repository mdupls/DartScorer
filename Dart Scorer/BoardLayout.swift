//
//  Boardswift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-14.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

private let MarkerOuterRatio: CGFloat = 0.99
private let MarkerInnerRatio: CGFloat = 0.97
private let DoubleOuterRatio: CGFloat = 0.75
private let DoubleInnerRatio: CGFloat = 0.7153
private let TripleOuterRatio: CGFloat = 0.4722
private let TripleInnerRatio: CGFloat = 0.4375
private let BullseyeRatio: CGFloat = 0.0694
private let DoubleBullseyeRatio: CGFloat = 0.0278

class BoardLayout {
    
    internal let model: BoardModel
    
    private var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var center: CGPoint { return CGPoint(x: frame.midX, y: frame.midY) }
    
    var diameter: CGFloat {
        return min(frame.width, frame.height)
    }
    
    var radius: CGFloat {
        return diameter / 2
    }
    
    var sweepAngle: CGFloat {
        return (CGFloat.pi * 2) / CGFloat(model.sectionCount)
    }
    
    internal var markerOuterRadius: CGFloat { return radius * MarkerOuterRatio }
    internal var markerInnerRadius: CGFloat { return radius * MarkerInnerRatio }
    internal var doubleOuterRadius: CGFloat { return radius * DoubleOuterRatio }
    internal var doubleInnerRadius: CGFloat { return radius * DoubleInnerRatio }
    internal var tripleOuterRadius: CGFloat { return radius * TripleOuterRatio }
    internal var tripleInnerRadius: CGFloat { return radius * TripleInnerRatio }
    internal var bullseyeRadius: CGFloat { return radius * BullseyeRatio }
    internal var doubleBullseyeRadius: CGFloat { return radius * DoubleBullseyeRatio }
    
    init(model: BoardModel) {
        self.model = model
    }
    
    func centerIn(frame: CGRect) -> CGRect {
        let diameter = min(frame.width, frame.height)
        let rect = CGRect(x: (frame.width - diameter) / 2, y: (frame.height - diameter) / 2, width: diameter, height: diameter)
        self.frame = rect
        return rect
    }
    
    // MARK: Private
    
    internal func slice(forAngle angle: CGFloat, radius: CGFloat) -> Target? {
        let normalizedAngle = angle < 0 ? angle + CGFloat.pi : angle - CGFloat.pi
        
        var index = Int(ceil(abs(normalizedAngle) / (sweepAngle / 2)) / 2.0)
        
        if angle < 0 {
            index = model.sectionCount - index
            if index >= model.sectionCount {
                index -= model.sectionCount
            }
        }
        
        var section: Section
        
        if radius < tripleInnerRadius {
            section = .Single
        } else if radius < tripleOuterRadius {
            section = .Triple
        } else if radius < doubleInnerRadius {
            section = .Single
        } else if radius < doubleOuterRadius {
            section = .Double
        } else {
            return nil
        }
        
        return model.target(forIndex: index, section: section)
    }
    
    internal func isDoubleBullseye(point: CGPoint) -> Bool {
        return point.distance(to: center) <= doubleBullseyeRadius
    }
    
    internal func isBullseye(point: CGPoint) -> Bool {
        return point.distance(to: center) <= bullseyeRadius
    }
    
    internal func slice(point: CGPoint) -> Target? {
        let originPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        let angle = atan2(originPoint.x, originPoint.y)
        
        return slice(forAngle: angle, radius: point.distance(to: center))
    }
    
}

extension BoardLayout {
    
    func target(forPoint point: CGPoint) -> Target? {
        if isDoubleBullseye(point: point) {
            return model.targetForBullseye(at: .Double)
        } else if isBullseye(point: point) {
            return model.targetForBullseye(at: .Single)
        }
        
        return slice(point: point)
    }
    
    func angle(forIndex index: Int) -> CGFloat {
        let startAngle = (CGFloat.pi / 2) * 3 - sweepAngle / 2
        
        return (startAngle + (CGFloat(index) * sweepAngle)).truncatingRemainder(dividingBy: CGFloat.pi * 2)
    }
    
}
