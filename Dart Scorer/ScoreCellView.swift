//
//  ScoreCellView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-31.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ScoreCellView: UICollectionViewCell {
    
    var hits: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var value: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var multiplier: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentMode = .redraw
    }
    
    func markerRect(_ rect: CGRect) -> CGRect {
        let diameter = min(rect.width, rect.height)
        return CGRect(x: (rect.width - diameter) / 2, y: (rect.height - diameter) / 2, width: diameter, height: diameter)
    }
    
    func centerRect(_ rect: CGRect) -> CGRect {
        let diameter = min(rect.width, rect.height) - 14 - 4
        return CGRect(x: (rect.width - diameter) / 2, y: (rect.height - diameter) / 2, width: diameter, height: diameter)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let markerRect = self.markerRect(rect)
        let centerRect = self.centerRect(rect)
        
        drawBackground(rect: centerRect)
        
        if let value = value, let multiplier = multiplier {
            let valueHeight = ceil(centerRect.height / 3)
            let spacing = ceil(valueHeight / 5)
            let multiplierHeight = ceil(valueHeight / 2)
            
            let valueFrame = CGRect(x: centerRect.minX, y: centerRect.minY + ceil((centerRect.height - valueHeight - spacing - multiplierHeight) / 2), width: centerRect.width, height: valueHeight)
            let multiplierFrame = CGRect(x: centerRect.minX, y: valueFrame.maxY + spacing, width: centerRect.width, height: multiplierHeight)
            
            draw(value: value, rect: valueFrame)
            draw(multiplier: multiplier, rect: multiplierFrame)
        } else if let value = value {
            draw(value: value, rect: centerRect)
        } else if let multiplier = multiplier {
            draw(multiplier: multiplier, rect: centerRect)
        }
        
        if let hits = hits {
            drawMarker(for: hits, rect: markerRect)
        }
    }
    
    // MARK: Private
    
    private func drawBackground(rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.addEllipse(in: rect)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.setAlpha(0.7)
        ctx.fillPath()
    }
    
    private func draw(value: Int, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let str = "\(value)"
        
        let font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)!
        let color = UIColor.black
        
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font
        ]
        
        ctx.saveGState()
        
        ctx.translateBy (x: rect.midX, y: rect.midY)
        
        let offset = str.size(attributes: attributes)
        ctx.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        ctx.restoreGState()
    }
    
    private func draw(multiplier: Int, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let str = "x\(multiplier)"
        
        let font = UIFont(name: "HelveticaNeue-UltraLight", size: 20)!
        let color = UIColor.black
        
        let attributes = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font
        ]
        
        ctx.saveGState()
        
        ctx.translateBy (x: rect.midX, y: rect.midY)
        
        let offset = str.size(attributes: attributes)
        ctx.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        ctx.restoreGState()
    }
    
    private func drawMarker(for multiplier: Int, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        
        ctx.translateBy (x: rect.midX, y: rect.midY)
        
        let sweep = CGFloat.pi * 2
        let startAngle: CGFloat = 0//(sweep * 3) / 2 + CGFloat.pi / 2
        
        var color: CGColor
        var marks: Int
        var maxMarks: Int
        
        if multiplier < 3 {
            marks = multiplier
            maxMarks = 3
            color = UIColor.hit.cgColor
        } else {
            marks = 1
            maxMarks = 1
            color = UIColor.open.cgColor
        }
        
        let spaceSweep: CGFloat = 0.1
        let spacesSweep = spaceSweep * CGFloat(maxMarks <= 1 ? 0 : maxMarks)
        let marksSweep = sweep - spacesSweep
        let markSweep = marksSweep / CGFloat(maxMarks)
        let angle = startAngle + (sweep - markSweep * CGFloat(marks) - spaceSweep * CGFloat(marks - 1)) / 2
        
        for mark in 0 ..< marks {
            let path = CGMutablePath()
            path.addArc(center: CGPoint(x: 0, y: 0), radiusStart: ceil(rect.height / 2), radiusEnd: ceil(rect.height / 2) - 7, angle: angle + CGFloat(mark) * (markSweep + spaceSweep), sweep: markSweep)
            
            ctx.addPath(path)
            ctx.setFillColor(color)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            ctx.fillPath()
        }
        
        ctx.restoreGState()
    }
    
}
