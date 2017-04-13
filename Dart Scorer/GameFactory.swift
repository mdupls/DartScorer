//
//  GameFactory.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class GameFactory {
    
    private let teams: [Team]
    
    init(teams: [Team]) {
        self.teams = teams
    }
    
    func createGame(config: GameConfig) -> CoreGame? {
        let model = config.model()
        var game: Game?
        
        let wrappedConfig = Config(config: config)
        
        let players = self.teams.map {
            return GamePlayer(team: $0)
        }
        
        // TODO: Swift 3 reflection APIs seem to be lacking. For now, just hard-code a mapping.
        switch config.name {
        case "Cricket":
            game = CricketGame(config: wrappedConfig, players: players)
        case "x01":
            game = X01Game(config: wrappedConfig, players: players)
        case "Shanghai":
            game = ShanghaiGame(config: wrappedConfig, players: players)
        case "Around the World":
            game = AroundTheWorldGame(config: wrappedConfig, players: players)
        default:
            game = nil
        }
        
        if let game = game {
            return CoreGame(game: game, model: model, players: players, config: wrappedConfig)
        }
        
        return nil
    }
    
}
