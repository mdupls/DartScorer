//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-01-09.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let DoubleOuterRatio: CGFloat = 0.75
    let DoubleInnerRatio: CGFloat = 0.7153
    let TripleOuterRatio: CGFloat = 0.4722
    let TripleInnerRatio: CGFloat = 0.4375
    let BullseyeRatio: CGFloat = 0.0694
    let DoubleBullseyeRatio: CGFloat = 0.0278

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let width: CGFloat = view.bounds.width
        let height: CGFloat = view.bounds.height
        
        let diameter = min(width, height)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        
        let path = CGMutablePath()
        
        let x = (width - diameter) / 2
        let y = (height - diameter) / 2
        
        let doubleOuterDiameter = diameter * DoubleOuterRatio
        let doubleInnerDiameter = diameter * DoubleInnerRatio
        let tripleOuterDiameter = diameter * TripleOuterRatio
        let tripleInnerDiameter = diameter * TripleInnerRatio
        let bullseyeDiameter = diameter * BullseyeRatio
        let doubleBullseyeDiamater = diameter * DoubleBullseyeRatio
        
        let board = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: diameter, height: diameter))
        let doubleOuterRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - doubleOuterDiameter) / 2, y: y + (diameter - doubleOuterDiameter) / 2, width: doubleOuterDiameter, height: doubleOuterDiameter))
        let doubleInnerRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - doubleInnerDiameter) / 2, y: y + (diameter - doubleInnerDiameter) / 2, width: doubleInnerDiameter, height: doubleInnerDiameter))
        let tripleOuterRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - tripleOuterDiameter) / 2, y: y + (diameter - tripleOuterDiameter) / 2, width: tripleOuterDiameter, height: tripleOuterDiameter))
        let tripleInnerRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - tripleInnerDiameter) / 2, y: y + (diameter - tripleInnerDiameter) / 2, width: tripleInnerDiameter, height: tripleInnerDiameter))
        let bullseyeRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - bullseyeDiameter) / 2, y: y + (diameter - bullseyeDiameter) / 2, width: bullseyeDiameter, height: bullseyeDiameter))
        let doubleBullseyeRing = UIBezierPath(ovalIn: CGRect(x: x + (diameter - doubleBullseyeDiamater) / 2, y: y + (diameter - doubleBullseyeDiamater) / 2, width: doubleBullseyeDiamater, height: doubleBullseyeDiamater))
        
        path.addPath(board.cgPath)
        path.addPath(doubleOuterRing.cgPath)
        path.addPath(doubleInnerRing.cgPath)
        path.addPath(tripleOuterRing.cgPath)
        path.addPath(tripleInnerRing.cgPath)
        path.addPath(bullseyeRing.cgPath)
        path.addPath(doubleBullseyeRing.cgPath)
        
        let radius = diameter / 2
        let center = CGPoint(x: x + radius, y: y + radius)
        let count: CGFloat = 20
        
        stride(from: CGFloat.pi / count, to: CGFloat.pi * 2, by: CGFloat.pi / (count / 2.0)).forEach {
            angle in
            
            let arc = UIBezierPath()
            arc.addArc(withCenter: center, radius: radius, startAngle: angle, endAngle: angle + CGFloat.pi, clockwise: true)
            arc.addLine(to: center)
            arc.close()
            
            path.addPath(arc.cgPath)
        }
        
        shapeLayer.path = path
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.yellow.cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        
        view.layer.addSublayer(shapeLayer);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

