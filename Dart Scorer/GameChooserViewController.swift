//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class GameChooserViewController: UITableViewController {
    
    private var config: GamesParser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config = GamesParser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playGame" {
            if let viewController = segue.destination as? GameViewController {
                let player1 = Player(name: "Michael")
                let player2 = Player(name: "Tegan")
                let player3 = Player(name: "Tuco")
                
                var players: [Player] = []
                players.append(player1)
                players.append(player2)
                players.append(player3)
                
                guard let index = tableView.indexPathForSelectedRow?.row, let game = config?.games[index] else {
                    return
                }
                guard let config = game["config"] as? String else {
                    return
                }
                
                viewController.game = GameFactory(players: players).createGame(config: config)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "playGame" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            guard let _ = config?.games[indexPath.row]["name"] as? String else {
                return false
            }
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config?.games.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
        
        populate(cell: cell as? GameViewCell, for: indexPath)
        
        return cell
    }
    
    // MARK: Private
    
    private func populate(cell: GameViewCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.label.text = config?.games[indexPath.row]["name"] as? String
    }
    
}

class GameViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}
