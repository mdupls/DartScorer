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
    
    private let indexMap: [Int] = [
        // Numbers for each section in the range [0, 2*PI)
        6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20, 1, 18, 4, 13
    ]
    
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
    
    var sections: [Int] {
        return _board?["sections"] as? [Int] ?? []
    }
    
    var bullseye: Bool {
        return _board?["bullseye"] as? Bool ?? false
    }
    
    func setup(model: BoardModel) {
        for section in sections {
            model.slice(forValue: section, section: .Single)?.enabled = true
            model.slice(forValue: section, section: .Double)?.enabled = true
            model.slice(forValue: section, section: .Triple)?.enabled = true
        }
        
        model.bullseye(section: .Single)?.enabled = bullseye
        model.bullseye(section: .Double)?.enabled = bullseye
    }
    
}
