//
//  GameParser.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation
import CoreGraphics

class GameConfig {
    
    let json: [String : Any]
    
    private let _bullseye: Int = 25
    private let _slices: [Int] = [ 20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5 ]
    private var _properties: [GameProperty]?
    
    init?(name: String) {
        let components = name.components(separatedBy: ".")
        
        guard components.count > 0 else {
            return nil
        }
        
        let name = components[0]
        let type = components.count > 1 ? components[1] : ""
        
        if let url = Bundle.main.url(forResource: name, withExtension: type) {
            do {
                let data = try Data(contentsOf: url)
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] else {
                    print("Invalid json file '\(name)'")
                    return nil
                }

                self.json = json
            } catch {
                print("Game config '\(name)' not found.")
                return nil
            }
        } else {
            return nil
        }
    }
    
    var id: String {
        return json["id"] as? String ?? ""
    }
    
    var name: String {
        return json["name"] as? String ?? ""
    }
    
    var bullseye: Int {
        return _board?["bullseye"] as? Int ?? _bullseye
    }
    
    var targets: [Int] {
        return _board?["targets"] as? [Int] ?? []
    }
    
    var slices: [Int] {
        return _board?["slices"] as? [Int] ?? _slices
    }
    
    func model() -> BoardModel {
        let slices = self.slices
        
        var bullseye: Int?
        if let firstValue = targets.first {
            if !slices.contains(firstValue) {
                bullseye = firstValue
            }
        }
        
        let model = BoardModel(slices: slices, bullseye: bullseye ?? self.bullseye)
        
        return model
    }
    
    var properties: [GameProperty] {
        if let properties = _properties {
            return properties
        }
        
        if let json = json["properties"] as? [Any] {
            var properties: [GameProperty] = []
            for item in json {
                if let obj = item as? [String: Any] {
                    if let property = GameProperty(json: obj, prefix: id) {
                        properties.append(property)
                    }
                }
            }
            _properties = properties
        } else {
            _properties = []
        }
        
        return _properties!
    }
    
    // MARK: Private
    
    private var _board: [String : Any]? {
        return json["board"] as? [String : Any]
    }
    
}

class Config {
    
    private let wrapped: GameConfig
    
    init(config: GameConfig) {
        self.wrapped = config
    }
    
    var slices: [Int] {
        return wrapped.slices
    }
    
    var name: String {
        return wrapped.name
    }
    
    var throwsPerTurn: Int {
        return wrapped.json["throwsPerTurn"] as? Int ?? 3
    }
    
    var showHitMarkers: Bool {
        return board?["showHitMarkers"] as? Bool ?? false
    }
    
    var targetHitsRequired: Int? {
        return wrapped.json["targetHitsRequired"] as? Int
    }
    
    var targets: [Int] {
        return board?["targets"] as? [Int] ?? []
    }
    
    func isBullseye(value: Int) -> Bool {
        return !slices.contains(value)
    }
    
    var properties: [GameProperty] {
        return wrapped.properties
    }
    
    // MARK: Private
    
    private var board: [String : Any]? {
        return wrapped.json["board"] as? [String : Any]
    }
    
}
