//
//  UIColor+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let red = (hex >> 24) & 0xff
        let green = (hex >> 16) & 0xff
        let blue = (hex >> 8) & 0xff
        let alpha = hex & 0xff
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 255, "Invalid alpha component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    static var metal: UIColor { return board }
    static var number: UIColor { return UIColor(hex: 0xF0FBF0FF) }
    static var board: UIColor { return UIColor(hex: 0x292821FF) }
    static var blackSlice: UIColor { return UIColor(hex: 0x292821FF) }
    static var whiteSlice: UIColor { return UIColor(hex: 0xF6E0A1FF) }
    static var redSlice: UIColor { return UIColor(hex: 0xFF1857FF) }
    static var greenSlice: UIColor { return UIColor(hex: 0x00984DFF) }
    static var bullseye: UIColor { return UIColor(hex: 0x00984DFF) }
    static var doubleBullseye: UIColor { return UIColor(hex: 0xFF1857FF) }
    
    static var open: UIColor { return UIColor.green }
    static var hit: UIColor { return UIColor.white }
    
    static var single: UIColor { return UIColor.white }
    static var double: UIColor { return UIColor.green }
    static var triple: UIColor { return UIColor.red }
    
}

let hitAlpha: CGFloat = 0.5
let hitForPointsAlpha: CGFloat = 0.7

let disabledTargetAlpha: CGFloat = 0.2
