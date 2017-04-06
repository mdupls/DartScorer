//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Variables
    
    var players: [Player]? {
        didSet {
            opponentsViewController?.players = players
            gameChooserViewController?.players = players
        }
    }
    
    weak var opponentsViewController: OpponentsViewController?
    weak var gameChooserViewController: GameChooserViewController?
    
    // MARK: Unwind Segues
    
    @IBAction func unwindFromPlayerChooser(segue: UIStoryboardSegue) {
        players = (segue.source as? PlayerChooserViewController)?.players
    }
    
    @IBAction func unwindFromGameOptions(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let persitence = PlayerPersistence(storage: CoreDataStorage())
        players = persitence.getPlayers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPlayers" {
            opponentsViewController = segue.destination as? OpponentsViewController
        } else if segue.identifier == "embedGameChooser" {
            gameChooserViewController = segue.destination as? GameChooserViewController
        }
    }
    
}
