//
//  GameProperty.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-05.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element : GameProperty {
    
    func property(id: String) -> Iterator.Element? {
        for property in self {
            if property.id == id {
                return property
            }
        }
        return nil
    }
    
}

class GameProperty {
    
    let id: String
    private let json: [String: Any]
    private let key: String
    
    init?(json: [String: Any], prefix: String) {
        self.json = json
        
        guard let id = json["id"] as? String, !id.isEmpty else {
            print("A game property must include a non-empty id")
            return nil
        }
        
        self.id = id
        self.key = "\(prefix)_\(id)"
    }
    
    var name: String? {
        return json["name"] as? String
    }
    
    var type: String? {
        return json["type"] as? String
    }
    
    var value: Any? {
        get {
            return UserDefaults.standard.value(forKey: key) ?? json["value"]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    var values: [Any]? {
        return json["values"] as? [Any]
    }
    
}
