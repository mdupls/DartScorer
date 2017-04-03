//
//  RoundView.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class RoundView: UIView {
    
    var layout: BoardLayout? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var round: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawBackground(rect: rect)
        drawRound(rect: rect, name: "Round \(round + 1)".localizedUppercase)
    }
    
    // MARK: Private
    
    private func drawBackground(rect: CGRect) {
        guard let layout = layout else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.board.cgColor)
        context.setAlpha(0.7)
        
        let height = layout.diameter / 20
        let sweep = CGFloat.pi / 4
        
        let path = CGMutablePath()
        path.addArc(center: center, radiusStart: layout.radius, radiusEnd: layout.radius + height, angle: (CGFloat.pi / 4) - (sweep / 2), sweep: sweep)
        
        context.addPath(path)
        context.fillPath()
    }
    
    private func drawRound(rect: CGRect, name: String) {
        guard let layout = layout else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // *******************************************************************
        // Scale & translate the context to have 0,0
        // at the centre of the screen maths convention
        // Obviously change your origin to suit...
        // *******************************************************************
        context.translateBy (x: rect.midX, y: rect.midY)
        context.scaleBy (x: 1, y: -1)
        
        let height = layout.diameter / 33
        let font = UIFont(name: "HelveticaNeue-Thin", size: height)!
        
        centreArcPerpendicular(text: name, context: context, radius: layout.radius + (height * 3) / 4, angle: -CGFloat.pi / 4, colour: UIColor.white, font: font, clockwise: false)
    }
    
    private func centreArcPerpendicular(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool) {
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
