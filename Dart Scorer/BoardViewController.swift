//
//  BoardViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {
    
    // MARK: Variables
    
    private var layout: BoardLayout?
    private var game: CoreGame?
    
    // MARK: IBOutlet
    
    @IBOutlet var boardView: BoardView!
    @IBOutlet var markerView: MarkerView!
    
    // MARK: IBAction
    
    @IBAction func didTapBoard(gesture: UITapGestureRecognizer) {
        if let game = game, let target = layout?.target(forPoint: gesture.location(in: view)) {
            game.score(target: target)
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player1 = Player(name: "Michael")
        let player2 = Player(name: "Tegan")
        
        var players: [Player] = []
        players.append(player1)
        players.append(player2)
        
        guard let game = GameFactory(players: players).createGame(name: "shanghai") else {
            return
        }
        
        game.add(observer: self)
        self.game = game
        
        let layout = BoardLayout(model: game.model)
        self.layout = layout
        boardView.layout = layout
        boardView.dataSource = game.model
        
        markerView.layout = layout
        markerView.dataSource = game
    }
    
}

extension BoardViewController: GameObserver {
    
    func hit(target: Target?, player: GamePlayer) {
        markerView?.setNeedsDisplay()
    }
    
    func nextRound() {
        boardView?.setNeedsDisplay()
    }
    
}
