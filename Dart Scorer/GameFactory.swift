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
    
    func createGame(name: String) -> CoreGame? {
        let parser = GameParser(name: name)
        let model = parser.model()
        var game: Game?
        
        // TODO: Swift 3 reflection APIs seem to be lacking. For now, just hard-code a mapping.
        switch name {
        case "cricket":
            game = CricketGame(model: model, config: parser.json)
        case "x01":
            game = X01Game(model: model, config: parser.json)
        case "shanghai":
            game = ShanghaiGame(model: model, config: parser.json)
        default:
            game = nil
        }
        
        if let game = game {
            return CoreGame(game: game, model: model, players: players, config: parser.json)
        }
        
        return nil
    }
    
}
