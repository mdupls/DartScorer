//
//  Properties.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-05.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class Properties {
    
    private let json: [Any]?
    private let _properties: [Property]
    
    var properties: [Property] {
        return _properties
    }
    
    init(json: [Any]?) {
        self.json = json
        
        if let json = json {
            var properties: [Property] = []
            for item in json {
                if let obj = item as? [String: Any] {
                    properties.append(Property(json: obj))
                }
            }
            _properties = properties
        } else {
            _properties = []
        }
    }
    
}

class Property {
    
    private let json: [String: Any]
    
    init(json: [String: Any]) {
        self.json = json
    }
    
    var id: String? {
        return json["id"] as? String
    }
    
    var name: String? {
        return json["name"] as? String
    }
    
    var type: String? {
        return json["type"] as? String
    }
    
    var value: Any? {
        return json["initial"]
    }
    
    var values: [Any]? {
        return json["values"] as? [Any]
    }
    
}
