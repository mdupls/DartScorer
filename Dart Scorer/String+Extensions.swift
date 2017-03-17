//
//  String+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func fontWith(height: CGFloat, fontSize: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightThin)
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesFontLeading, attributes: [NSFontAttributeName: font], context: nil)
        
        if boundingBox.height > height {
            return fontWith(height: height, fontSize: fontSize - 10)
        }
        
        return font
    }
    
}
