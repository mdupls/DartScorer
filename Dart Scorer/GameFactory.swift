//
//  GameFactory.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GameFactory {
    
    private let players: [Player]
    
    init(players: [Player]) {
        self.players = players
    }
    
    func createGame(config: String) -> CoreGame? {
        let parser = GameParser(config: config)
        let model = parser.model()
        var game: Game?
        
        let config = Config(json: parser.json)
        
        // TODO: Swift 3 reflection APIs seem to be lacking. For now, just hard-code a mapping.
        switch parser.name {
        case "Cricket":
            game = CricketGame(model: model, config: config)
        case "X01":
            game = X01Game(model: model, config: config)
        case "Shanghai":
            game = ShanghaiGame(model: model, config: config)
        default:
            game = nil
        }
        
        if let game = game {
            return CoreGame(game: game, model: model, players: players, config: config)
        }
        
        return nil
    }
    
}

class Config {
    
    let json: [String: Any]?
    
    init(json: [String: Any]?) {
        self.json = json
    }
    
    var rounds: Int {
        return sequentialTargets?.count ?? 0
    }
    
    var throwsPerTurn: Int {
        return 3
    }
    
    // MARK: Private
    
    private var sequentialTargets: [[Int]]? {
        return board?["targets"] as? [[Int]]
    }
    
    private var board: [String : Any]? {
        return json?["board"] as? [String : Any]
    }
    
}
