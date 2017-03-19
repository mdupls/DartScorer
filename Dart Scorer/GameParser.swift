//
//  GameParser.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreGraphics

class GameParser {
    
    private let _bullseye: Int = 25
    private let _slices: [Int] = [ 20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 ]
    
    private var json: [String : Any]?
    
    init(name: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: "json")
        {
            do {
                let data = try Data(contentsOf: url)
                
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

                self.json = json as? [String : Any]
            } catch {
                
            }
        }
    }
    
    private var _board: [String : Any]? {
        return json?["board"] as? [String : Any]
    }
    
    var targets: [Int] {
        return _board?["targets"] as? [Int] ?? []
    }
    
    var slices: [Int] {
        return _board?["slices"] as? [Int] ?? _slices
    }
    
    var hasBullseye: Bool {
        return _board?["bullseye"] as? Bool ?? false
    }
    
    var bullseye: Int {
        return _board?["bullseye"] as? Int ?? _bullseye
    }
    
    func model() -> BoardModel {
        let model = BoardModel(slices: slices, bullseye: bullseye)
        
        for value in targets {
            model.target(forValue: value, section: .Single)?.enabled = true
            model.target(forValue: value, section: .Double)?.enabled = true
            model.target(forValue: value, section: .Triple)?.enabled = true
        }
        
        model.targetForBullseye(at: .Single)?.enabled = hasBullseye
        model.targetForBullseye(at: .Double)?.enabled = hasBullseye
        
        return model
    }
    
}
