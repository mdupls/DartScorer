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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout?.frame = frame
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let frame = layout?.frame else { return }
        
        drawBoard(rect: frame)
        drawSlices(rect: frame)
        drawBullseye(rect: frame)
        drawNumbers(rect: frame)
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
        drawSingleArc(rect: rect, angle: angle, sweep: sweep, section: section, color: colors[0])
        drawDoubleArc(rect: rect, angle: angle, sweep: sweep, section: section, color: colors[1])
        drawTripleArc(rect: rect, angle: angle, sweep: sweep, section: section, color: colors[1])
    }
    
    private func drawSingleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, section: Int, color: CGColor) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        if let target = dataSource.boardView(self, targetAt: section, for: .single) {
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.bullseyeRadius, radiusEnd: layout.tripleInnerRadius, target: target, color: color)
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.tripleOuterRadius, radiusEnd: layout.doubleInnerRadius, target: target, color: color)
        }
    }
    
    private func drawDoubleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, section: Int, color: CGColor) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        if let target = dataSource.boardView(self, targetAt: section, for: .double) {
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.doubleInnerRadius, radiusEnd: layout.doubleOuterRadius, target: target, color: color)
        }
    }
    
    private func drawTripleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, section: Int, color: CGColor) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        if let target = dataSource.boardView(self, targetAt: section, for: .triple) {
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.tripleInnerRadius, radiusEnd: layout.tripleOuterRadius, target: target, color: color)
        }
    }
    
    private func drawArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, radiusStart: CGFloat, radiusEnd: CGFloat, target: Target, color: CGColor) {
        guard let dataSource = dataSource else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let alpha = delegate?.boardView(self, alphaForTarget: target) ?? 1
        let state = dataSource.boardView(self, stateFor: target)
        
        let path = CGMutablePath()
        path.addArc(center: center, radiusStart: radiusStart, radiusEnd: radiusEnd, angle: angle, sweep: sweep)
        
        ctx.addPath(path)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setFillColor(state.color?.cgColor ?? color)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setAlpha(alpha * state.alpha)
        ctx.drawPath(using: .fillStroke)
    }
    
    private func drawBullseye(rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        drawSingleBullseye(rect: rect)
        drawDoubleBullseye(rect: rect)
    }
    
    private func drawSingleBullseye(rect: CGRect) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        if let target = dataSource.boardView(self, bullsEyeTargetFor: .single) {
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            
            let alpha = delegate?.boardView(self, alphaForTarget: target) ?? 1
            let state = dataSource.boardView(self, stateFor: target)
            let radius = layout.bullseyeRadius
            let bullseyeRect = CGRect(x: rect.midX - radius, y: rect.midY - radius, width: radius * 2, height: radius * 2)
            
            ctx.addEllipse(in: bullseyeRect)
            ctx.setFillColor(state.color?.cgColor ?? UIColor.bullseye.cgColor)
            ctx.setAlpha(alpha * state.alpha)
            ctx.drawPath(using: .fillStroke)
        }
    }
    
    private func drawDoubleBullseye(rect: CGRect) {
        guard let layout = layout else { return }
        guard let dataSource = dataSource else { return }
        
        if let target = dataSource.boardView(self, bullsEyeTargetFor: .double) {
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            
            let alpha = delegate?.boardView(self, alphaForTarget: target) ?? 1
            let state = dataSource.boardView(self, stateFor: target)
            let radius = layout.doubleBullseyeRadius
            let bullseyeRect = CGRect(x: rect.midX - radius, y: rect.midY - radius, width: radius * 2, height: radius * 2)
            
            ctx.addEllipse(in: bullseyeRect)
            ctx.setFillColor(state.color?.cgColor ?? UIColor.doubleBullseye.cgColor)
            ctx.setAlpha(alpha * state.alpha)
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
        let fontSize = (layout.radius - layout.doubleOuterRadius) / 2
        let font = UIFont(name: "HelveticaNeue-Thin", size: fontSize)!
        let points = pointsForLabels(sections: sections, x: x, y: y, radius: radius, offset: (CGFloat.pi / 2) * 3)
        let attr = [ NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.number ]
        
        for (index, p) in points.enumerated() {
            if let target = dataSource.boardView(self, targetAt: index, for: .single) {
                let state = dataSource.boardView(self, stateFor: target)
                let alpha = delegate?.boardView(self, alphaForTarget: target) ?? 1
                
                let string = "\(target.value)"
                let text = CFAttributedStringCreate(nil, string as CFString!, attr as CFDictionary)
                let line = CTLineCreateWithAttributedString(text!)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
                
                ctx.setAlpha(alpha * state.alpha)
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
            return UIColor.open
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
    
    func boardView(_ boardView: BoardView, alphaForTarget target: Target) -> CGFloat
    
}

protocol BoardViewDataSource: class {
    
    func numberOfSections(in boardView: BoardView) -> Int
    
    func boardView(_ boardView: BoardView, targetAt index: Int, for section: Section) -> Target?
    
    func boardView(_ boardView: BoardView, bullsEyeTargetFor section: Section) -> Target?
    
    func boardView(_ boardView: BoardView, stateFor target: Target) -> TargetState
    
}
