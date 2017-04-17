//
//  ViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-23.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class GameChooserViewController: UITableViewController {
    
    // MARK: Variables
    
    private var config: GamesConfig?
    
    var teams: [Team]?
    
    var gamesCount: Int {
        return config?.games.count ?? 0
    }
    
    var teamsCount: Int {
        return teams?.count ?? 0
    }
    
    var storage: CoreDataStorage {
        return ((UIApplication.shared.delegate as? AppDelegate)?.storage)!
    }
    
    private var gameForSegue: CoreGame?
    private var cutOpponentsIfNecessary: Bool?
    
    // MARK: Unwind Segues
    
    @IBAction func unwindFromPlayerChooser(segue: UIStoryboardSegue) {
        retrieveItems()
        
        tableView?.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
    
    @IBAction func unwindFromGameOptions(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.hideEmptyRows()
        config = GamesConfig()
        
        retrieveItems()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playGame" {
            if let viewController = segue.destination as? GameViewController {
                viewController.game = gameForSegue
                gameForSegue = nil
                cutOpponentsIfNecessary = nil
            }
        } else if segue.identifier == "gameOptions" {
            if let viewController = (segue.destination as? UINavigationController)?.childViewControllers.first as? PropertiesViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    if let name = config?.games[indexPath.row]["config"] as? String {
                        viewController.config = GameConfig(name: name)
                    }
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "playGame" {
            guard let teams = teams, !teams.isEmpty else {
                performSegue(withIdentifier: "players", sender: nil)
                
                return false
            }
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            guard let gameConfig = config?.games[indexPath.row] else {
                return false
            }
            guard let file = gameConfig["config"] as? String else {
                return false
            }
            guard let config = GameConfig(name: file) else {
                return false
            }
            guard let game = GameFactory(teams: teams).createGame(config: config) else {
                return false
            }
            
            gameForSegue = game
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 180
        case 1:
            return 95
        default:
            return 84
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 75
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Opponents"
        }
        return nil
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return gamesCount
        default:
            return max(1, teamsCount)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
            populate(cell: cell as? GameViewCell, for: indexPath)
        default:
            if teamsCount == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "addPlayersCell", for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath)
                populate(cell: cell as? TeamViewCell, for: indexPath)
            }
        }
        
        return cell
    }
    
    // MARK: Private
    
    private func populate(cell: GameViewCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let game = config?.games[indexPath.row] else { return }
        
        if let fontName = game["font"] as? String {
            cell.label.font = UIFont(name: fontName, size: 40)
        } else {
            cell.label.font = UIFont.boldSystemFont(ofSize: 40)
        }
        
        if let textColor = game["foregroundColor"] as? String {
            let color = UIColor(textColor)
            cell.label.textColor = color
            cell.tintColor = color
        } else {
            cell.label.textColor = UIColor.black
            cell.tintColor = cell.window?.tintColor
        }
        
        if let backgroundColor = game["backgroundColor"] as? String {
            cell.backgroundColor = UIColor(backgroundColor).withAlphaComponent(0.8)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.label.text = game["name"] as? String
    }
    
    private func populate(cell: TeamViewCell?, for indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let team = teams?[indexPath.row] else { return }
        
        cell.team = team
        cell.nameLabel.text = team.playerNames
    }
    
    private func retrieveItems() {
        let persitence = TeamPersistence(storage: storage)
        teams = persitence.teams()
    }
    
    private func display(title: String, message: String, completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            completion()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

class TitleViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.font = UIFont(name: "28 Days Later", size: 40)
    }
    
}

class GameViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        backgroundColor = backgroundColor?.withAlphaComponent(highlighted ? 1 : 0.8)
    }
    
}

class TeamViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: TeamIconView!
    
    var team: Team? {
        didSet {
            iconView?.count = team?.players?.count ?? 0
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        containerView.backgroundColor = UIColor.board.withAlphaComponent(highlighted ? 0.4 : 0.2)
    }
    
}

class AddPlayersCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        containerView.backgroundColor = UIColor.board.withAlphaComponent(highlighted ? 0.4 : 0.2)
    }
    
}
