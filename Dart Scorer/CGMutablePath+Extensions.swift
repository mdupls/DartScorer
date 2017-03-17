//
//  CGMutablePath+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

extension CGMutablePath {
    
    func addArc(center: CGPoint, radiusStart: CGFloat, radiusEnd: CGFloat, angle: CGFloat, sweep: CGFloat) {
        let arc = UIBezierPath()
        arc.addArc(withCenter: center, radius: radiusStart, startAngle: angle, endAngle: angle + sweep, clockwise: true)
        arc.addArc(withCenter: center, radius: radiusEnd, startAngle: angle + sweep, endAngle: angle, clockwise: false)
        arc.close()
        
        addPath(arc.cgPath)
    }
    
}
