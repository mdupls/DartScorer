//
//  BoardView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-18.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var layout: BoardLayout? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var dataSource: BoardViewDataSource? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var delegate: BoardViewDelegate?
    
    private var sliceColors: [[CGColor]] {
        return [
            [
                UIColor.blackSlice.cgColor,
                UIColor.redSlice.cgColor
            ],[
                UIColor.whiteSlice.cgColor,
                UIColor.greenSlice.cgColor
            ]
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        guard let layout = layout else { return }
        
        let frame = layout.centerIn(frame: rect)
        
        drawBoard(rect: frame)
        drawSlices(rect: frame)
        drawBullseye(rect: frame)
        drawNumbers(rect: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    // MARK: Private
    
    private func drawBoard(rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.addEllipse(in: rect)
        ctx.setFillColor(UIColor.board.cgColor)
        ctx.fillPath()
    }
    
    private func drawSlices(rect: CGRect) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        let sections = dataSource.numberOfSections(in: self)
        let sweep = (CGFloat.pi * 2) / CGFloat(sections)
        let colors = sliceColors

        for section in 0 ..< sections {
            let angle = layout.angle(forIndex: section)
            
            drawSlice(rect: rect, angle: angle, sweep: sweep, section: section, colors: colors[section % 2])
        }
    }
    
    private func drawSlice(rect: CGRect, angle: CGFloat, sweep: CGFloat, section: Int, colors: [CGColor]) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        // Single
        if let target = dataSource.boardView(self, targetAt: section, for: .Single) {
            let state = dataSource.boardView(self, stateFor: target)
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.bullseyeRadius, radiusEnd: layout.tripleInnerRadius, target: target, state: state, color: colors[0])
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.tripleOuterRadius, radiusEnd: layout.doubleInnerRadius, target: target, state: state, color: colors[0])
        }
        
        // Double
        if let target = dataSource.boardView(self, targetAt: section, for: .Double) {
            let state = dataSource.boardView(self, stateFor: target)
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.doubleInnerRadius, radiusEnd: layout.doubleOuterRadius, target: target, state: state, color: colors[1])
        }
        
        // Triple
        if let target = dataSource.boardView(self, targetAt: section, for: .Triple) {
            let state = dataSource.boardView(self, stateFor: target)
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.tripleInnerRadius, radiusEnd: layout.tripleOuterRadius, target: target, state: state, color: colors[1])
        }
    }
    
    private func drawArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, radiusStart: CGFloat, radiusEnd: CGFloat, target: Target, state: TargetState, color: CGColor) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let path = CGMutablePath()
        path.addArc(center: center, radiusStart: radiusStart, radiusEnd: radiusEnd, angle: angle, sweep: sweep)
        
        ctx.addPath(path)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setFillColor(state.color?.cgColor ?? color)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setAlpha(state.alpha)
        ctx.drawPath(using: .fillStroke)
    }
    
    private func drawBullseye(rect: CGRect) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        // Single
        if let target = dataSource.boardView(self, bullsEyeTargetFor: .Single) {
            let state = dataSource.boardView(self, stateFor: target)
            
            let bullseyeRect = CGRect(x: rect.midX - layout.bullseyeRadius, y: rect.midY - layout.bullseyeRadius, width: layout.bullseyeRadius * 2, height: layout.bullseyeRadius * 2)
            
            ctx.addEllipse(in: bullseyeRect)
            ctx.setFillColor(state.color?.cgColor ?? UIColor.bullseye.cgColor)
            ctx.setAlpha(state.alpha)
            ctx.drawPath(using: .fillStroke)
        }
        
        // Double
        if let target = dataSource.boardView(self, bullsEyeTargetFor: .Double) {
            let state = dataSource.boardView(self, stateFor: target)
            
            let bullseyeRect = CGRect(x: rect.midX - layout.doubleBullseyeRadius, y: rect.midY - layout.doubleBullseyeRadius, width: layout.doubleBullseyeRadius * 2, height: layout.doubleBullseyeRadius * 2)
            
            ctx.addEllipse(in: bullseyeRect)
            ctx.setFillColor(state.color?.cgColor ?? UIColor.doubleBullseye.cgColor)
            ctx.setAlpha(state.alpha)
            ctx.drawPath(using: .fillStroke)
        }
    }
    
    private func drawNumbers(rect: CGRect) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: frame.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.setTextDrawingMode(.fillStroke)
        
        let x: CGFloat = rect.midX
        let y: CGFloat = rect.midY
        
        let sections = dataSource.numberOfSections(in: self)
        let radius = (layout.doubleOuterRadius + layout.radius) / 2
        let textHeight = (layout.radius - layout.doubleOuterRadius) * 2 / 3
        let font = "20".fontWith(height: textHeight, fontSize: 140)
        let points = pointsForLabels(sections: sections, x: x, y: y, radius: radius, offset: (CGFloat.pi / 2) * 3)
        let attr = [ NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.number ]
        
        for (index, p) in points.enumerated() {
            if let target = dataSource.boardView(self, targetAt: index, for: .Single) {
                let state = dataSource.boardView(self, stateFor: target)
                
                let string = "\(target.value)"
                let text = CFAttributedStringCreate(nil, string as CFString!, attr as CFDictionary)
                let line = CTLineCreateWithAttributedString(text!)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
                
                ctx.setAlpha(state.alpha)
                ctx.textPosition = CGPoint(x: p.x - bounds.midX, y: p.y - bounds.midY)
                
                CTLineDraw(line, ctx)
            }
        }
        
        ctx.restoreGState()
    }
    
    private func pointsForLabels(sections: Int, x: CGFloat, y: CGFloat, radius: CGFloat, offset: CGFloat) -> [CGPoint] {
        let angle = (CGFloat.pi * 2) / CGFloat(sections)
        var points: [CGPoint] = []
        for i in (1 ... sections).reversed() {
            let x2 = x - radius * cos(angle * CGFloat(i) + offset)
            let y2 = y - radius * sin(angle * CGFloat(i) + offset)
            points.append(CGPoint(x: x2, y: y2))
        }
        return points
    }
    
}

extension TargetState {
    
    var color: UIColor? {
        switch self {
        case .initial:
            return nil
        case .open:
            return UIColor.green
        case .closed:
            return nil
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .initial:
            return 1
        case .open:
            return 1
        case .closed:
            return 0.05
        }
    }
    
}

protocol BoardViewDelegate: class {
    
    
}

protocol BoardViewDataSource: class {
    
    func numberOfSections(in boardView: BoardView) -> Int
    
    func boardView(_ boardView: BoardView, targetAt index: Int, for section: Section) -> Target?
    
    func boardView(_ boardView: BoardView, bullsEyeTargetFor section: Section) -> Target?
    
    func boardView(_ boardView: BoardView, stateFor target: Target) -> TargetState
    
}
