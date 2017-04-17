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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        contentMode = .redraw
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let text = text else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let height = rect.width * 0.75
        let font = UIFont(name: "HelveticaNeue-Light", size: height)!
        let color = UIColor.white
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let attributes = [NSForegroundColorAttributeName: color,
                          NSFontAttributeName: font,
                          NSParagraphStyleAttributeName: paragraphStyle]
        
        let offset = text.size(attributes: attributes)
        
        context.saveGState()
        
        context.setFillColor(UIColor.board.withAlphaComponent(0.4).cgColor)
        context.fill(rect)
        
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.rotate(by: -CGFloat.pi / 2)
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        
        // Draw the text
        text.draw(in: CGRect(x: max(0, (offset.width - rect.height) / 2), y: max(0, (offset.height - rect.width) / 2), width: min(rect.height, offset.width), height: min(rect.width, offset.height)), withAttributes: attributes)
    
        context.restoreGState()
    }
    
}
