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
        return 0//game?.players.count ?? 0
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
    
}
