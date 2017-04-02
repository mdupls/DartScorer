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
    
    var requiredHits: Int? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var target: Target? {
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
        
        if let target = target {
            let valueHeight = ceil(centerRect.height / 3)
            let spacing = ceil(valueHeight / 5)
            let multiplierHeight = ceil(valueHeight / 2)
            
            let valueFrame = CGRect(x: centerRect.minX, y: centerRect.minY + ceil((centerRect.height - valueHeight - spacing - multiplierHeight) / 2), width: centerRect.width, height: valueHeight)
            let multiplierFrame = CGRect(x: centerRect.minX, y: valueFrame.maxY + spacing, width: centerRect.width, height: multiplierHeight)
            
            drawValue(target: target, rect: valueFrame)
            drawMultiplier(target: target, rect: multiplierFrame)
        }
        
        if let hits = hits {
            drawMarker(for: hits, rect: markerRect)
        }
    }
    
    // MARK: Private
    
    private func drawBackground(rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        
        ctx.addEllipse(in: rect)
        ctx.setFillColor((target?.section ?? .single).color.cgColor)
        ctx.setAlpha((target?.section ?? .single).alpha)
        ctx.fillPath()
        
        ctx.restoreGState()
    }
    
    private func drawValue(target: Target, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let str = "\(target.value)"
        
        let font = UIFont(name: "HelveticaNeue", size: 40)!
        
        let attributes = [
            NSForegroundColorAttributeName: target.section.textColor,
            NSFontAttributeName: font
        ]
        
        ctx.saveGState()
        
        ctx.translateBy (x: rect.midX, y: rect.midY)
        
        let offset = str.size(attributes: attributes)
        ctx.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        ctx.restoreGState()
    }
    
    private func drawMultiplier(target: Target, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let str = "x\(target.section.rawValue)"
        
        let font = UIFont(name: "HelveticaNeue", size: 20)!
        
        let attributes = [
            NSForegroundColorAttributeName: target.section.textColor,
            NSFontAttributeName: font
        ]
        
        let offset = str.size(attributes: attributes)
        
        ctx.saveGState()
        
        ctx.translateBy (x: rect.midX, y: rect.midY)
        ctx.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        // Draw text.
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        ctx.restoreGState()
    }
    
    private func drawMarker(for marks: Int, rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        
        let sweep = CGFloat.pi * 2
        let startAngle: CGFloat = 0//(sweep * 3) / 2 + CGFloat.pi / 2
        let color = UIColor.white.cgColor
        let maxMarks = max(requiredHits ?? 0, marks)
        
        ctx.setFillColor(color)
        ctx.setAlpha(0.5)
        ctx.translateBy (x: rect.midX, y: rect.midY)
        
        let spaceSweep: CGFloat = 0.1
        let spacesSweep = spaceSweep * CGFloat(maxMarks <= 1 ? 0 : maxMarks)
        let marksSweep = sweep - spacesSweep
        let markSweep = marksSweep / CGFloat(maxMarks)
        let angle = startAngle + (sweep - markSweep * CGFloat(marks) - spaceSweep * CGFloat(marks - 1)) / 2
        
        for mark in 0 ..< marks {
            let path = CGMutablePath()
            path.addArc(center: CGPoint(x: 0, y: 0), radiusStart: ceil(rect.height / 2), radiusEnd: ceil(rect.height / 2) - 7, angle: angle + CGFloat(mark) * (markSweep + spaceSweep), sweep: markSweep)
            
            ctx.addPath(path)
            ctx.fillPath()
        }
        
        ctx.restoreGState()
    }
    
}

extension Section {
    
    var color: UIColor {
        switch self {
        case .single:
            return UIColor.single
        case .double:
            return UIColor.double
        case .triple:
            return UIColor.triple
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .single:
            return UIColor.darkGray
        case .double:
            return UIColor.white
        case .triple:
            return UIColor.white
        }
    }
    
    var alpha: CGFloat {
        return 0.5
    }
    
}
