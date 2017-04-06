//
//  GamesParser.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GamesConfig {
    
    private var _json: [String: Any]?
    
    init() {
        if let url = Bundle.main.url(forResource: "config", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                
                self._json = json as? [String : Any]
            } catch {
                
            }
        }
    }
    
    var json: [String: Any]? {
        return _json
    }
    
    var games: [[String : Any]] {
        return _json?["games"] as? [[String : Any]] ?? []
    }
    
}
