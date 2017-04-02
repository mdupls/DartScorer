//
//  UIColor+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    static var metal: UIColor { return board }
    static var number: UIColor { return UIColor(hex: 0xF0FBF0) }
    static var board: UIColor { return UIColor(hex: 0x292821) }
    static var blackSlice: UIColor { return UIColor(hex: 0x292821) }
    static var whiteSlice: UIColor { return UIColor(hex: 0xF6E0A1) }
    static var redSlice: UIColor { return UIColor(hex: 0xFF1857) }
    static var greenSlice: UIColor { return UIColor(hex: 0x00984D) }
    static var bullseye: UIColor { return UIColor(hex: 0x00984D) }
    static var doubleBullseye: UIColor { return UIColor(hex: 0xFF1857) }
    
    static var open: UIColor { return UIColor.green }
    static var hit: UIColor { return UIColor.orange }
    
    static var single: UIColor { return UIColor.white }
    static var double: UIColor { return UIColor.green }
    static var triple: UIColor { return UIColor.red }
    
}
