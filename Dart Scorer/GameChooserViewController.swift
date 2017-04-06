//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class GameChooserViewController: UITableViewController {
    
    private var config: GamesConfig?
    
    var players: [Player]? {
        didSet {
            
        }
    }
    
    var count: Int {
        return config?.games.count ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyRows()
        config = GamesConfig()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playGame" {
            if let viewController = segue.destination as? GameViewController {
                guard let index = tableView.indexPathForSelectedRow?.row, let game = config?.games[index] else {
                    return
                }
                guard let config = game["config"] as? String else {
                    return
                }
                
                viewController.game = GameFactory(players: players!).createGame(config: config)
            }
        } else if segue.identifier == "addPlayers" {
            if let viewController = (segue.destination as? UINavigationController)?.childViewControllers.first as? PlayerChooserViewController {
                viewController.players = players
            }
        } else if segue.identifier == "gameOptions" {
            if let viewController = (segue.destination as? UINavigationController)?.childViewControllers.first as? PropertiesViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    if let name = config?.games[indexPath.row]["config"] as? String {
                        viewController.config = GameConfig(config: name)
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "playGame" {
            guard let players = players, !players.isEmpty else {
                performSegue(withIdentifier: "addPlayers", sender: nil)
                
                return false
            }
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
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
