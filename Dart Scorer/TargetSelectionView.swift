//
//  SelectionView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-31.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class TargetSelectionView: UIView {
    
    // MARK: Variables
    
    var layout: BoardLayout?
    weak var boardView: BoardView?
    weak var game: CoreGame?
    var player: GamePlayer?
    var round: Int = 0
    
    private var shouldDrawSelector: Bool = false
    private let bullseyeEnlargeFactor: CGFloat = 2.5
    private let sliceEnlargeFactor: CGFloat = 1.5
    fileprivate var hasMoved: Bool = false
    
    var strategy: TargetStrategy?
    weak var delegate: TargetSelectionViewDelegate?
    
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
    
    // MARK: IBActions
    
    @IBAction func didPanBoard(gesture: UIPanGestureRecognizer) {
        guard let game = game else { return }
        guard let player = player else { return }
        guard let layout = layout else { return }
        
        switch gesture.state {
        case .began:
            hasMoved = false
            let point = gesture.location(in: self)
            
            if point.distance(to: center) <= layout.bullseyeRadius * bullseyeEnlargeFactor {
                strategy = BullseyeStrategy(game: game, player: player, layout: layout, round: round, enlargeFactor: bullseyeEnlargeFactor)
            } else {
                strategy = SliceStrategy(game: game, player: player, layout: layout, round: round, enlargeFactor: sliceEnlargeFactor)
            }
            
            if strategy?.start(with: point) ?? false {
                boardView?.setNeedsDisplay()
            }
            
            shouldDrawSelector = true
        case .ended:
            shouldDrawSelector = false
            
            if let target = strategy?.target {
                delegate?.targetSelection(self, didHit: target)
            }
        case .possible:
            Void()
        case .changed:
            let point = gesture.location(in: self)
            
            if strategy?.move(with: point) ?? false {
                hasMoved = true
                boardView?.setNeedsDisplay()
            } else if !hasMoved {
                hasMoved = true
                boardView?.setNeedsDisplay()
            }
        case .cancelled:
            shouldDrawSelector = false
        case .failed:
            shouldDrawSelector = false
        }
        
        if !shouldDrawSelector {
            strategy = nil
            boardView?.setNeedsDisplay()
        }
        
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if shouldDrawSelector, let target = strategy?.target {
            if target.value > 20 {
                drawBullseye(rect: rect, target: target)
            } else {
                drawSlice(rect: rect, target: target)
            }
        }
    }
    
    // MARK: Private
    
    private func drawSlice(rect: CGRect, target: Target) {
        guard let game = game else { return }
        guard let layout = layout else { return }
        guard let index = game.model.index(of: target) else { return }
        
        let sweep = (CGFloat.pi * 2) / CGFloat(game.model.sectionCount)
        let angle = layout.angle(forIndex: index)
        let colors = sliceColors[index % 2]
        
        drawSingleArc(rect: rect, angle: angle, sweep: sweep, value: target.value, color: colors[0], section: target.section)
        drawDoubleArc(rect: rect, angle: angle, sweep: sweep, value: target.value, color: colors[1], section: target.section)
        drawTripleArc(rect: rect, angle: angle, sweep: sweep, value: target.value, color: colors[1], section: target.section)
    }
    
    private func drawSingleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, value: Int, color: CGColor, section: Section?) {
        guard let game = game else { return }
        guard let layout = layout else { return }
        
        if let target = game.model.target(forValue: value, section: .single) {
            let highlighted = target.section == section
            let enlargeFactor = strategy?.enlargeFactor ?? 1
            let growthFactor = max(0, enlargeFactor - 1)
            
            let angle = highlighted ? angle - (sweep * growthFactor) / 2 : angle
            let sweep = highlighted ? sweep * enlargeFactor : sweep
            let highlightColor = highlighted ? UIColor.hit.cgColor : nil
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.bullseyeRadius, radiusEnd: layout.tripleInnerRadius, target: target, color: color, highlightColor: highlightColor, section: section)
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: layout.tripleOuterRadius, radiusEnd: layout.doubleInnerRadius, target: target, color: color, highlightColor: highlightColor, section: section)
        }
    }
    
    private func drawDoubleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, value: Int, color: CGColor, section: Section?) {
        guard let game = game else { return }
        guard let layout = layout else { return }
        
        if let target = game.model.target(forValue: value, section: .double) {
            let highlighted = target.section == section
            let enlargeFactor = strategy?.enlargeFactor ?? 1
            let growthFactor = max(0, enlargeFactor - 1)
            
            let angle = highlighted ? angle - (sweep * growthFactor) / 2 : angle
            let sweep = highlighted ? sweep * enlargeFactor : sweep
            let highlightColor = highlighted ? UIColor.hit.cgColor : nil
            let radiusStart = highlighted ? layout.doubleInnerRadius - layout.radius * 0.03 : layout.doubleInnerRadius
            let radiusEnd = highlighted ? layout.doubleOuterRadius + layout.radius * 0.03 : layout.doubleOuterRadius
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: radiusStart, radiusEnd: radiusEnd, target: target, color: color, highlightColor: highlightColor, section: section)
        }
    }
    
    private func drawTripleArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, value: Int, color: CGColor, section: Section?) {
        guard let game = game else { return }
        guard let layout = layout else { return }
        
        if let target = game.model.target(forValue: value, section: .triple) {
            let highlighted = target.section == section
            let enlargeFactor = strategy?.enlargeFactor ?? 1
            let growthFactor = max(0, enlargeFactor - 1)
            
            let angle = highlighted ? angle - (sweep * growthFactor) / 2 : angle
            let sweep = highlighted ? sweep * enlargeFactor : sweep
            let highlightColor = highlighted ? UIColor.hit.cgColor : nil
            let radiusStart = highlighted ? layout.tripleInnerRadius - layout.radius * 0.03 : layout.tripleInnerRadius
            let radiusEnd = highlighted ? layout.tripleOuterRadius + layout.radius * 0.03 : layout.tripleOuterRadius
            
            drawArc(rect: rect, angle: angle, sweep: sweep, radiusStart: radiusStart, radiusEnd: radiusEnd, target: target, color: color, highlightColor: highlightColor, section: section)
        }
    }
    
    private func drawArc(rect: CGRect, angle: CGFloat, sweep: CGFloat, radiusStart: CGFloat, radiusEnd: CGFloat, target: Target, color: CGColor, highlightColor: CGColor? = nil, section: Section?) {
        guard let game = game else { return }
        guard let player = player else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let state = game.game.game(game, stateFor: target, player: player, round: round)
        
        let path = CGMutablePath()
        path.addArc(center: center, radiusStart: radiusStart, radiusEnd: radiusEnd, angle: angle, sweep: sweep)
        
        ctx.addPath(path)
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setFillColor(highlightColor ?? state.color?.cgColor ?? color)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setAlpha(state.alpha)
        ctx.drawPath(using: .fillStroke)
    }
    
    private func drawBullseye(rect: CGRect, target: Target) {
        guard let game = game else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setStrokeColor(UIColor.metal.cgColor)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        guard let singleTarget = game.model.targetForBullseye(at: .single) else { return }
        guard let doubleTarget = game.model.targetForBullseye(at: .double) else { return }
        
        drawSingleBullseye(rect: rect, target: singleTarget, section: target.section)
        drawDoubleBullseye(rect: rect, target: doubleTarget, section: target.section)
    }
    
    private func drawSingleBullseye(rect: CGRect, target: Target, section: Section?) {
        guard let game = game else { return }
        guard let player = player else { return }
        guard let layout = layout else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let state = game.game.game(game, stateFor: target, player: player, round: round)
        let radius = layout.bullseyeRadius * (strategy?.enlargeFactor ?? 1)
        let bullseyeRect = CGRect(x: rect.midX - radius, y: rect.midY - radius, width: radius * 2, height: radius * 2)
        
        var highlightColor: CGColor?
        if target.section == section {
            highlightColor = UIColor.hit.cgColor
        }
        
        ctx.addEllipse(in: bullseyeRect)
        ctx.setFillColor(highlightColor ?? state.color?.cgColor ?? UIColor.bullseye.cgColor)
        ctx.setAlpha(state.alpha)
        ctx.drawPath(using: .fillStroke)
    }
    
    private func drawDoubleBullseye(rect: CGRect, target: Target, section: Section?) {
        guard let game = game else { return }
        guard let player = player else { return }
        guard let layout = layout else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let state = game.game.game(game, stateFor: target, player: player, round: round)
        let radius = layout.doubleBullseyeRadius * (strategy?.enlargeFactor ?? 1)
        let bullseyeRect = CGRect(x: rect.midX - radius, y: rect.midY - radius, width: radius * 2, height: radius * 2)
        
        var highlightColor: CGColor?
        if target.section == section {
            highlightColor = UIColor.hit.cgColor
        }
        
        ctx.addEllipse(in: bullseyeRect)
        ctx.setFillColor(highlightColor ?? state.color?.cgColor ?? UIColor.doubleBullseye.cgColor)
        ctx.setAlpha(state.alpha)
        ctx.drawPath(using: .fillStroke)
    }
    
}

extension TargetSelectionView: BoardViewDelegate {
    
    func boardView(_ boardView: BoardView, alphaForTarget target: Target) -> CGFloat {
        if hasMoved && strategy?.target != nil && strategy?.initialSection == .single {
            return strategy?.target?.value == target.value ? 1 : disabledTargetAlpha
        }
        return 1
    }
    
}

extension TargetSelectionView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        
        return layout?.board(hasPoint: point) ?? false
    }
    
}

protocol TargetSelectionViewDelegate: class {
    
    func targetSelection(_ selection: TargetSelectionView, didHit target: Target)
    
}

protocol TargetStrategy {
    
    var target: Target? { get }
    var initialSection: Section? { get }
    var enlargeFactor: CGFloat { get }
    
    func start(with point: CGPoint) -> Bool
    
    func move(with point: CGPoint) -> Bool
    
}

class BullseyeStrategy: TargetStrategy {
    
    let game: CoreGame
    let player: GamePlayer
    let layout: BoardLayout
    let round: Int
    let enlargeFactor: CGFloat
    
    var target: Target?
    var initialSection: Section?
    
    init(game: CoreGame, player: GamePlayer, layout: BoardLayout, round: Int, enlargeFactor: CGFloat) {
        self.game = game
        self.player = player
        self.layout = layout
        self.round = round
        self.enlargeFactor = enlargeFactor
    }
    
    func start(with point: CGPoint) -> Bool {
        target = calculateTarget(for: point)
        
        return true
    }
    
    func move(with point: CGPoint) -> Bool {
        target = calculateTarget(for: point)
        
        return false
    }
    
    func calculateTarget(for point: CGPoint) -> Target? {
        let section = calculateSection(for: point)
        
        if let target = game.model.targetForBullseye(at: section) {
            let state = game.game.game(game, stateFor: target, player: player, round: round)
            if state != .closed {
                return target
            }
        }
        return nil
    }
    
    func calculateSection(for point: CGPoint) -> Section {
        let distance = point.distance(to: layout.center)
        
        var section: Section
        if distance < layout.bullseyeRadius * 2 * enlargeFactor {
            section = .single
        } else {
            section = .double
        }
        
        return section
    }
    
}

class SliceStrategy: TargetStrategy {
    
    let game: CoreGame
    let player: GamePlayer
    let layout: BoardLayout
    let round: Int
    let enlargeFactor: CGFloat
    
    var target: Target?
    var initialSection: Section?
    
    init(game: CoreGame, player: GamePlayer, layout: BoardLayout, round: Int, enlargeFactor: CGFloat) {
        self.game = game
        self.player = player
        self.layout = layout
        self.round = round
        self.enlargeFactor = enlargeFactor
    }
    
    func start(with point: CGPoint) -> Bool {
        target = calculateTarget(for: point)
        initialSection = calculateSection(for: point)
        
        return true
    }
    
    func move(with point: CGPoint) -> Bool {
        var isNewTarget: Bool
        
        // Only update the board if the touch started from a valid section. This improves the usability.
        // If you start dragging from a number, then you are locked on a particular target. If you start
        // dragging from anywhere else, you can switch between different targets during the same gesture.
        let startedDoubleOrTriple = initialSection != .single
        
        let target = calculateTarget(for: point, fixed: startedDoubleOrTriple ? nil : self.target)
        if startedDoubleOrTriple {
            isNewTarget = target !== self.target
        } else {
            isNewTarget = false
        }
        
        self.target = target
        
        return isNewTarget
    }
    
    private func calculateTarget(for point: CGPoint, fixed fixedTarget: Target? = nil) -> Target? {
        let section = calculateSection(for: point, target: fixedTarget)
        
        if let target = fixedTarget ?? layout.slice(for: point) {
            if let target = game.model.target(forValue: target.value, section: section) {
                let state = game.game.game(game, stateFor: target, player: player, round: round)
                if state != .closed {
                    return target
                }
            }
        }
        return nil
    }
    
    private func calculateSection(for point: CGPoint, target: Target? = nil) -> Section {
        let distance = point.distance(to: layout.center)
        var section: Section
        
        if distance <= layout.tripleOuterRadius {
            section = .triple
        } else if distance <= layout.doubleOuterRadius {
            section = .double
        } else {
            section = .single
        }
        
        return section
    }
    
    
}
