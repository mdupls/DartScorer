//
//  BoardLayout.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-14.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

class BoardLayout {
    
    private let DoubleOuterRatio: CGFloat = 0.75
    private let DoubleInnerRatio: CGFloat = 0.7153
    private let TripleOuterRatio: CGFloat = 0.4722
    private let TripleInnerRatio: CGFloat = 0.4375
    private let BullseyeRatio: CGFloat = 0.0694
    private let DoubleBullseyeRatio: CGFloat = 0.0278
    
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    private var x: CGFloat { return (width - diameter) / 2 }
    private var y: CGFloat { return (height - diameter) / 2 }
    
    internal var center: CGPoint { return CGPoint(x: x + radius, y: y + radius) }
    
    var diameter: CGFloat {
        return min(width, height)
    }
    
    var radius: CGFloat {
        return diameter / 2
    }
    
    internal var doubleOuterRadius: CGFloat { return radius * DoubleOuterRatio }
    internal var doubleInnerRadius: CGFloat { return radius * DoubleInnerRatio }
    internal var tripleOuterRadius: CGFloat { return radius * TripleOuterRatio }
    internal var tripleInnerRadius: CGFloat { return radius * TripleInnerRatio }
    internal var bullseyeRadius: CGFloat { return radius * BullseyeRatio }
    internal var doubleBullseyeRadius: CGFloat { return radius * DoubleBullseyeRatio }
    
    init() {
        
    }
    
}

class BoardCoordinateSystem {
    
    private let layout: BoardLayout
    
    init(layout: BoardLayout) {
        self.layout = layout
    }
    
    func target(forPoint point: CGPoint, model: BoardModel) -> Target? {
        if isDoubleBullseye(point: point) {
            return model.bullseye(section: .Double)
        } else if isBullseye(point: point) {
            return model.bullseye(section: .Single)
        }
        
        return slice(point: point, model: model)
    }
    
    private func isDoubleBullseye(point: CGPoint) -> Bool {
        return point.distance(to: layout.center) <= layout.doubleBullseyeRadius
    }
    
    private func isBullseye(point: CGPoint) -> Bool {
        return point.distance(to: layout.center) <= layout.bullseyeRadius
    }
    
    private func slice(point: CGPoint, model: BoardModel) -> Target? {
        let originPoint = CGPoint(x: point.x - layout.center.x, y: point.y - layout.center.y)
        let angle = atan2(originPoint.x, originPoint.y)
        
        return model.slice(forAngle: angle, radius: point.distance(to: layout.center))
    }
    
}

extension BoardLayout {
    
    func number(startAngle: CGFloat, sweep: CGFloat, number: Int) -> UILabel {
        let value = "\(number)"
        let textHeight = (radius - doubleOuterRadius) * 2 / 3
        let textWidth = textHeight * 1.4
        
        let font = value.fontWith(height: textHeight, fontSize: 140)
        
        let label = UILabel(frame: CGRect(x: ceil(center.x - textWidth / 2), y: ceil(center.y - textHeight / 2), width: ceil(textWidth), height: ceil(textHeight)))
        label.font = font
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.text = value
        
        let angle = startAngle + sweep / 2
        
        let distance = radius - textHeight + (textHeight / 4)
        let x1 = cos(angle) * distance
        let y1 = sin(angle) * distance
        
//        let textAngle = angle < CGFloat.pi - 0.001 && angle > 0 ? angle - CGFloat.pi / 2 : angle + CGFloat.pi / 2
        
        var transform = label.layer.transform
        transform = CATransform3DTranslate(transform, x1, y1, 0)
//        transform = CATransform3DRotate(transform, textAngle, 0, 0, 1)
        label.layer.transform = transform
        
        return label
    }
    
    func pie(startAngle: CGFloat, sweep: CGFloat) -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let center = CGPoint(x: x + radius, y: y + radius)
        
        let path = CGMutablePath()
        
        // Inner
        path.addArc(center: center, radiusStart: bullseyeRadius, radiusEnd: tripleInnerRadius, angle: startAngle, sweep: sweep)
        
        // Outer
        path.addArc(center: center, radiusStart: tripleOuterRadius, radiusEnd: doubleInnerRadius, angle: startAngle, sweep: sweep)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
    func triple(startAngle: CGFloat, sweep: CGFloat) -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let center = CGPoint(x: x + radius, y: y + radius)
        
        let path = CGMutablePath()
        
        path.addArc(center: center, radiusStart: tripleInnerRadius, radiusEnd: tripleOuterRadius, angle: startAngle, sweep: sweep)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
    func double(startAngle: CGFloat, sweep: CGFloat) -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let center = CGPoint(x: x + radius, y: y + radius)
        
        let path = CGMutablePath()
        
        path.addArc(center: center, radiusStart: doubleInnerRadius, radiusEnd: doubleOuterRadius, angle: startAngle, sweep: sweep)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
    func bullseye() -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let bullseyeRing = UIBezierPath(ovalIn: CGRect(x: x + radius - bullseyeRadius, y: y + radius - bullseyeRadius, width: bullseyeRadius * 2, height: bullseyeRadius * 2))
        
        let path = CGMutablePath()

        path.addPath(bullseyeRing.cgPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
    func doubleBullseye() -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let doubleBullseyeRing = UIBezierPath(ovalIn: CGRect(x: x + radius - doubleBullseyeRadius, y: y + radius - doubleBullseyeRadius, width: doubleBullseyeRadius * 2, height: doubleBullseyeRadius * 2))
        
        let path = CGMutablePath()
        
        path.addPath(doubleBullseyeRing.cgPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
    func outer() -> CAShapeLayer {
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        let board = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: diameter, height: diameter))
        
        let path = CGMutablePath()
        
        path.addPath(board.cgPath)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor(hex: 0xF0FBF0).cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.contentsScale = UIScreen.main.scale
        
        return shapeLayer
    }
    
}
