//
//  Game.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import Foundation

protocol Game: MarkerViewDataSource {
    
    var model: BoardModel { get }
    
    var currentPlayer: Player { get }
    
    func start()
    
    func score(player: Player, target: Target?)
    
}
