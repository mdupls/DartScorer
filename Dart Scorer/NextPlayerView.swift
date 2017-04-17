//
//  NextPlayerView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class NextPlayerView: UIView {
    
    var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let text = text else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let height = rect.width / 2
        let font = UIFont(name: "HelveticaNeue", size: height)!
        let color = UIColor.white
        
        let attributes = [NSForegroundColorAttributeName: color,
                          NSFontAttributeName: font]
        
        let offset = text.size(attributes: attributes)
        
        context.setFillColor(UIColor.board.withAlphaComponent(0.4).cgColor)
        context.fill(rect)
        
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.rotate(by: -CGFloat.pi / 2)
        
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        // Draw the text
        text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
    }
    
}
