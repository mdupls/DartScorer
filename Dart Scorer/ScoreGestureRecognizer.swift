//
//  ScoreGestureRecognizer.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-01.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ScoreGestureRecognizer: UIGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
    
}
