//
//  MarkerView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-18.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    
    var layout: BoardLayout? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var dataSource: MarkerViewDataSource? {
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
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        guard let dataSource = dataSource else { return }
        guard let layout = layout else { return }
        
        let sections = dataSource.numberOfSections(in: self)
        let sweep = (CGFloat.pi * 2) / CGFloat(sections)
        
        ctx.setFillColor(UIColor.hit.cgColor)
        
        for section in 0 ..< sections {
            let hits = dataSource.boardView(self, hitsForSection: section)
            
            if hits > 0 {
                let startAngle = layout.angle(forIndex: section)
                
                let maxMarks = dataSource.boardView(self, maxMarksForSection: section)
                let marksForPoints = max(0, hits - maxMarks)
                let leadingSpaceSweep: CGFloat = 0.05
                
                if marksForPoints > 0 {
                    let markSweep = sweep - leadingSpaceSweep * 2
                    let angle = startAngle - markSweep + leadingSpaceSweep
                    
                    ctx.setAlpha(hitForPointsAlpha)
                    
                    drawMark(ctx: ctx, angle: angle, markSweep: markSweep)
                } else {
                    let marks = min(maxMarks, hits)
                    let spaceSweep: CGFloat = 0.01
                    let spacesSweep = spaceSweep * CGFloat(maxMarks - 1) + leadingSpaceSweep * 2
                    let marksSweep = sweep - spacesSweep
                    let markSweep = marksSweep / CGFloat(maxMarks)
                    let angle = startAngle + (sweep - markSweep * CGFloat(marks) - spaceSweep * CGFloat(marks - 1)) / 2
                    
                    ctx.setAlpha(hitAlpha / 2)
                    
                    for mark in 0 ..< marks {
                        drawMark(ctx: ctx, mark: mark, angle: angle, markSweep: markSweep, spaceSweep: spaceSweep)
                    }
                }
                
                ctx.fillPath()
            }
        }
    }
    
    // MARK: Private
    
    private func drawMark(ctx: CGContext, mark: Int = 1, angle: CGFloat, markSweep: CGFloat, spaceSweep: CGFloat = 0) {
        guard let layout = layout else { return }
        
        let path = CGMutablePath()
        path.addArc(center: center, radiusStart: layout.markerInnerRadius, radiusEnd: layout.markerOuterRadius, angle: angle + CGFloat(mark) * (markSweep + spaceSweep), sweep: markSweep)
        
        ctx.addPath(path)
    }
    
}

protocol MarkerViewDataSource {
    
    func numberOfSections(in markerView: MarkerView) -> Int
    
    func boardView(_ markerView: MarkerView, maxMarksForSection section: Int) -> Int
    
    func boardView(_ markerView: MarkerView, hitsForSection section: Int) -> Int
    
    func bullsEyeMarks(in markerView: MarkerView) -> Int
    
}
