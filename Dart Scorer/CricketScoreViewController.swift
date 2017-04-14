//
//  CricketScoreViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-08.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class CricketScoreViewController: UIViewController, ScoreView {
    
    // MARK: Variables
    
    var game: CoreGame?
    var config: Config?
    
    var count: Int {
        return config?.targets.count ?? 0
    }
    
    var numberOfPlayers: Int {
        return game?.players.count ?? 0
    }
    
    var round: Int = 0 {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hideEmptyRows()
        tableView.backgroundColor = UIColor(hex: 0xffffff55)
    }
    
    // MARK: Private
    
    fileprivate func populate(cell: CricketScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let game = game else { return }
        guard let target = config?.targets[indexPath.row] else { return }
        
        let count = game.players.count
        var overallState: TargetState = .closed
        
        if count >= 1 {
            let player = game.players[0]
            let hits = player.hits(for: target)
            let state = game.state(for: target, player: player, round: round)
            
            cell.player1View.hits = hits
            state.apply(view: cell.player1View)
            
            if state != .closed {
                overallState = .initial
            }
        }
        if count >= 2 {
            let player = game.players[1]
            let hits = player.hits(for: target)
            let state = game.state(for: target, player: player, round: round)
            
            cell.player2View.hits = hits
            state.apply(view: cell.player2View)
            
            if state != .closed {
                overallState = .initial
            }
        }
        if count >= 3 {
            let player = game.players[2]
            let hits = player.hits(for: target)
            let state = game.state(for: target, player: player, round: round)
            
            cell.player3View.hits = hits
            state.apply(view: cell.player3View)
            
            if state != .closed {
                overallState = .initial
            }
        }
        if count >= 4 {
            let player = game.players[3]
            let hits = player.hits(for: target)
            let state = game.state(for: target, player: player, round: round)
            
            cell.player4View.hits = hits
            state.apply(view: cell.player4View)
            
            if state != .closed {
                overallState = .initial
            }
        }
        
        cell.targetLabel.text = target == 25 ? "B" : "\(target)"
        overallState.apply(view: cell.targetView)
        overallState.apply(view: cell)
    }
    
    fileprivate func populate(header: CricketHeaderCellView?) {
        guard let header = header else { return }
        guard let game = game else { return }
        
        let count = game.players.count
        
        header.targetScoreLabel.text = "\(round + 1)"
        
        if count >= 1 {
            let player = game.players[0]
            let score = game.score(forPlayer: player, round: round) ?? 0
            header.player1ScoreLabel.text = "\(score)"
            header.player1Label.text = player.name
        }
        if count >= 2 {
            let player = game.players[1]
            let score = game.score(forPlayer: player, round: round) ?? 0
            header.player2ScoreLabel.text = "\(score)"
            header.player2Label.text = player.name
        }
        if count >= 3 {
            let player = game.players[2]
            let score = game.score(forPlayer: player, round: round) ?? 0
            header.player3ScoreLabel.text = "\(score)"
            header.player3Label.text = player.name
        }
        if count >= 4 {
            let player = game.players[3]
            let score = game.score(forPlayer: player, round: round) ?? 0
            header.player4ScoreLabel.text = "\(score)"
            header.player4Label.text = player.name
        }
    }
    
}

// MARK: UITableViewDelegate

extension CricketScoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell: UITableViewCell?
        
        switch numberOfPlayers {
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "twoPlayerHeaderCell")
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "threePlayerHeaderCell")
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "fourPlayerHeaderCell")
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "onePlayerHeaderCell")
        }
        
        populate(header: cell as? CricketHeaderCellView)
        
        return cell?.contentView
    }
    
}

// MARK: UITableViewDataSource

extension CricketScoreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch numberOfPlayers {
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "twoPlayerScoreCell", for: indexPath)
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "threePlayerScoreCell", for: indexPath)
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "fourPlayerScoreCell", for: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "onePlayerScoreCell", for: indexPath)
        }
        
        populate(cell: cell as? CricketScoreCellView, indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: PageViewControllerPage

extension CricketScoreViewController: PageViewControllerPage {
    
    func didBecomeActive(in pageViewController: GameViewController) {
        tableView?.reloadData()
    }
    
}

class CricketScoreCellView: UITableViewCell {
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var targetView: UIView!
    
    @IBOutlet weak var player1View: CricketHitView!
    @IBOutlet weak var player2View: CricketHitView!
    @IBOutlet weak var player3View: CricketHitView!
    @IBOutlet weak var player4View: CricketHitView!
    
}

class CricketHeaderCellView: UITableViewCell {
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var player4Label: UILabel!
    
    @IBOutlet weak var targetScoreLabel: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    @IBOutlet weak var player3ScoreLabel: UILabel!
    @IBOutlet weak var player4ScoreLabel: UILabel!
    
}

fileprivate extension TargetState {
    
    func apply(view: UIView) {
        switch self {
        case .closed:
            view.alpha = 0.2
        case .initial:
            view.alpha = 1
        case .open:
            view.alpha = 1
        }
    }
    
    func apply(view: UITableViewCell) {
        switch self {
        case .closed:
            view.backgroundColor = UIColor.lightGray
        case .initial:
            view.backgroundColor = UIColor.white
        case .open:
            view.backgroundColor = UIColor.white
        }
    }
    
}
