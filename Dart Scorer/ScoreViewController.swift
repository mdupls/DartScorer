//
//  ScoreViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-19.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ScoreViewController: UITableViewController {
    
    // MARK: Variables
    
    var game: CoreGame?
    
    private var count: Int {
        return game?.players.count ?? 0
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UITableViewDelegate
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerScoreCell", for: indexPath)
        
        populate(cell: cell as? ScoreCellView, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: Private
    
    private func populate(cell: ScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let player = game?.players[indexPath.row] else { return }
        
        let score = game?.score(for: player.score())
        
        cell.nameLabel.text = player.name
        cell.scoreLabel.text = "\(score ?? 0)"
    }
    
}

class ScoreCellView: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
}
