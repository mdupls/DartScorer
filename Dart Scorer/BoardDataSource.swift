//
//  BoardDataSource.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-28.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

class BoardDataSource {
    
    let game: CoreGame
    let player: GamePlayer
    
    var round: Int = 0
    
    init(game: CoreGame, player: GamePlayer) {
        self.game = game
        self.player = player
    }
    
}

extension BoardDataSource: BoardViewDataSource {
    
    func numberOfSections(in boardView: BoardView) -> Int {
        return game.model.sectionCount
    }
    
    func boardView(_ boardView: BoardView, targetAt index: Int, for section: Section) -> Target? {
        return game.model.slice(forIndex: index, section: section)
    }
    
    func boardView(_ boardView: BoardView, bullsEyeTargetFor section: Section) -> Target? {
        return game.model.targetForBullseye(at: section)
    }
    
    func boardView(_ boardView: BoardView, stateFor target: Target) -> TargetState {
        return game.game.game(game, stateFor: target, player: player, round: round)
    }
    
}
