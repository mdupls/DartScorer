//
//  BoardView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-18.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class NameView: UIView {
    
    var round: Int?
    
    var player: GamePlayer? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate var name: String? {
        if let round = round {
            return player?.player(for: round)?.name
        }
        return nil
    }
    
    fileprivate var team: String? {
        if let team = player?.team, (team.players?.count ?? 0) > 1, let playerNames = team.playerNames {
            return playerNames
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var accumulatedHeight: CGFloat?
        
        if let name = name {
            let height = rect.height / 13
            let radius = rect.height / 2 - height / 2
            let font = UIFont(name: "HelveticaNeue", size: height)!
            drawName(rect: rect, radius: radius, height: height, name: name, font: font)
            
            accumulatedHeight = height
        }
        
        if let team = team {
            let height = rect.height / 35
            let radius = rect.height / 2 - (accumulatedHeight ?? 0) - height / 2
            let font = UIFont(name: "HelveticaNeue", size: height)!
            drawName(rect: rect, radius: radius, height: height, name: team, font: font)
        }
    }
    
    // MARK: Private
    
    private func drawName(rect: CGRect, radius: CGFloat, height: CGFloat, name: String, font: UIFont) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        
        // *******************************************************************
        // Scale & translate the context to have 0,0
        // at the centre of the screen maths convention
        // Obviously change your origin to suit...
        // *******************************************************************
        context.translateBy (x: rect.midX, y: rect.midY)
        context.scaleBy (x: 1, y: -1)
        
        centreArcPerpendicular(text: name, context: context, radius: radius, angle: CGFloat.pi / 2, colour: UIColor.white, font: font, clockwise: true)
        
        context.restoreGState()
    }
    
    private func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool){
        // *******************************************************
        // This draws the String str around an arc of radius r,
        // with the text centred at polar angle theta
        // *******************************************************
        
        let l = str.characters.count
        let attributes = [NSFontAttributeName: font]
        
        let characters: [String] = str.characters.map { String($0) } // An array of single character strings, each character in str
        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
        
        // Calculate the arc subtended by each letter and their total
        for i in 0 ..< l {
            arcs += [chordToArc(characters[i].size(attributes: attributes).width, radius: r)]
            totalArc += arcs[i]
        }
        
        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection = clockwise ? -CGFloat(Double.pi / 2) : CGFloat(Double.pi / 2)
        
        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        var thetaI = theta - direction * totalArc / 2
        
        for i in 0 ..< l {
            thetaI += direction * arcs[i] / 2
            // Call centerText with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * arcs[i] / 2
        }
    }
    
    private func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        // *******************************************************
        // Simple geometry
        // *******************************************************
        return 2 * asin(chord / (2 * radius))
    }
    
    private func centre(text str: String, context: CGContext, radius r:CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************
        
        // Set the text attributes
        let attributes = [NSForegroundColorAttributeName: c,
                          NSFontAttributeName: font]
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(attributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }
    
}
