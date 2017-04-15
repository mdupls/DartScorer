//
//  ScoreViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-19.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

protocol ScoreView: class {
    
    var game: CoreGame? { get set }
    
    var round: Int { get set }
    
}

class ScoreViewController: UIViewController, ScoreView {
    
    // MARK: Variables
    
    var game: CoreGame?
    
    var count: Int {
        return players?.count ?? 0
    }
    
    var round: Int = 0 {
        didSet {
            update()
        }
    }
    
    fileprivate var players: [GamePlayer]?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyRows()
        tableView.backgroundColor = UIColor(hex: 0xffffff55)
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableViewHeightConstraint.constant = 150
    }
    
    // MARK: Private
    
    fileprivate func populate(cell: ScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let player = players?[indexPath.row] else { return }
        
        let score = game?.score(forPlayer: player)
        
        cell.nameLabel.text = player.name
        cell.scoreLabel.text = "\(score ?? 0)"
        cell.rankImageView.isHidden = indexPath.row > 0 || player.totalHits == 0
        
        if (player.team.players?.count ?? 0) > 1 {
            let playerNames = player.team.players?.map({ (item) -> String in
                return (item as? Player)?.name ?? ""
            })
            
            cell.playersLabel?.text = playerNames?.joined(separator: ", ")
        } else {
            cell.playersLabel?.text = nil
        }
    }
    
    fileprivate func update() {
        players = game?.rankedPlayers()
        
        tableView?.reloadData()
    }
    
}

// MARK: UITableViewDelegate

extension ScoreViewController: UITableViewDelegate {
    
}

// MARK: UITableViewDataSource

extension ScoreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let player = players?[indexPath.row]
        
        if (player?.team.players?.count ?? 1) == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "playerScoreCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "teamScoreCell", for: indexPath)
        }
        
        populate(cell: cell as? ScoreCellView, indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: PageViewControllerPage

extension ScoreViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        update()
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        
    }
    
}

class ScoreCellView: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var playersLabel: UILabel?
    
}
