//
//  GameViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-20.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    var player: GamePlayer?
    var game: CoreGame?
    var round: Int = 0 {
        didSet {
            boardViewController?.round = round
            roundViewController?.round = round
        }
    }
    
    weak var boardViewController: BoardViewController?
    weak var roundViewController: RoundViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "board" {
            boardViewController = segue.destination as? BoardViewController
            boardViewController?.player = player
            boardViewController?.game = game
            boardViewController?.round = round
        } else if segue.identifier == "round" {
            roundViewController = segue.destination as? RoundViewController
            roundViewController?.player = player
            roundViewController?.round = round
        }
    }
    
}
