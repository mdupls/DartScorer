//
//  Boardswift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-14.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

private let BoardRatio: CGFloat = 0.9
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
    
    var frame: CGRect {
        get {
            return _frame
        }
        set {
            let diameter = min(newValue.width, newValue.height) * BoardRatio
            let rect = CGRect(x: (newValue.width - diameter) / 2, y: (newValue.height - diameter) / 2, width: diameter, height: diameter)
            
            _diameter = diameter
            _center = CGPoint(x: newValue.midX, y: newValue.midY)
            _frame = rect
        }
    }
    
    var diameter: CGFloat {
        return _diameter
    }
    
    var radius: CGFloat {
        return _diameter / 2
    }
    
    var center: CGPoint {
        return _center
    }
    
    var sweepAngle: CGFloat {
        return (CGFloat.pi * 2) / CGFloat(model.sectionCount)
    }
    
    private var _diameter: CGFloat = 0
    private var _center: CGPoint = CGPoint(x: 0, y: 0)
    private var _frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
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
    
    func board(hasPoint point: CGPoint) -> Bool {
        return center.distance(to: point) <= radius
    }
    
    // MARK: Private
    
    internal func slice(forAngle angle: CGFloat, radius: CGFloat) -> Target? {
        let normalizedAngle = angle < 0 ? angle + CGFloat.pi : angle - CGFloat.pi
        
        var index = Int(ceil(abs(normalizedAngle) / (sweepAngle / 2)) / 2)
        
        if angle < 0 {
            index = model.sectionCount - index
            if index >= model.sectionCount {
                index -= model.sectionCount
            }
        }
        
        return model.slice(forIndex: index)
    }
    
}

extension BoardLayout {
    
    func slice(for point: CGPoint) -> Target? {
        let originPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        let angle = atan2(originPoint.x, originPoint.y)
        
        return slice(forAngle: angle, radius: point.distance(to: center))
    }
    
    func angle(forIndex index: Int) -> CGFloat {
        let startAngle = (CGFloat.pi / 2) * 3 - sweepAngle / 2
        
        return (startAngle + (CGFloat(index) * sweepAngle)).truncatingRemainder(dividingBy: CGFloat.pi * 2)
    }
    
}
