//
//  CGPoint+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    func distance(to: CGPoint) -> CGFloat {
        return sqrt((x - to.x) * (x - to.x) + (y - to.y) * (y - to.y))
    }
    
}
