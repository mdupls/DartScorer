//
//  CricketHitView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-09.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class CricketHitView: UIView {
    
    var hits: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let hits = hits, hits > 0 {
            let dimension = min(rect.width, rect.height) * 0.6
            let hitFrame = CGRect(x: rect.minX + (rect.width - dimension) / 2, y: rect.minY + (rect.height - dimension) / 2, width: dimension, height: dimension)
            
            drawHit(rect: hitFrame, hits: hits)
        }
    }
    
    // MARK: Private
    
    private func drawHit(rect: CGRect, hits: Int) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setStrokeColor(UIColor.board.cgColor)
        ctx.setLineWidth(6)
        
        let path = CGMutablePath()
        
        if hits >= 3 {
            path.addEllipse(in: rect)
        }
        
        if hits >= 2 {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }
        
        if hits >= 1 {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        
        ctx.addPath(path)
        ctx.strokePath()
    }
    
}
