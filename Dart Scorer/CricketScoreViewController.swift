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
        
        let image = UIImage(named: "wood3")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        tableView.backgroundView = imageView
    }
    
    // MARK: Private
    
    fileprivate func populate(cell: CricketScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let game = game else { return }
        guard let target = config?.targets[indexPath.row] else { return }
        
        let overallState = cell.populate(with: game.players, game: game, target: target, round: round)
        
        cell.targetLabel.text = target == 25 ? "B" : "\(target)"
        overallState.apply(view: cell.targetView)
        overallState.apply(view: cell)
    }
    
    fileprivate func populate(header: CricketHeaderCellView?) {
        guard let header = header else { return }
        guard let game = game else { return }
        
        header.targetScoreLabel.text = "\(round + 1)"
        header.populate(with: game.players, game: game)
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
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "fivePlayerHeaderCell")
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "sixPlayerHeaderCell")
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
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "fivePlayerScoreCell", for: indexPath)
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "sixPlayerScoreCell", for: indexPath)
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "onePlayerScoreCell", for: indexPath)
        }
        
        populate(cell: cell as? CricketScoreCellView, indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: PageViewControllerPage

extension CricketScoreViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        tableView?.reloadData()
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        
    }
    
}

class CricketScoreCellView: UITableViewCell {
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var targetView: UIView!
    
    @IBOutlet weak var player1View: CricketHitView!
    @IBOutlet weak var player2View: CricketHitView?
    @IBOutlet weak var player3View: CricketHitView?
    @IBOutlet weak var player4View: CricketHitView?
    @IBOutlet weak var player5View: CricketHitView?
    @IBOutlet weak var player6View: CricketHitView?
    
}

extension CricketScoreCellView {
    
    var playerViews: [CricketHitView] {
        var views: [CricketHitView] = [player1View]
        
        if let view = player2View {
            views.append(view)
            
            if let view = player3View {
                views.append(view)
                
                if let view = player4View {
                    views.append(view)
                    
                    if let view = player5View {
                        views.append(view)
                        
                        if let view = player6View {
                            views.append(view)
                        }
                    }
                }
            }
        }
        
        return views
    }
    
    func populate(with players: [GamePlayer], game: CoreGame, target: Int, round: Int) -> TargetState {
        var overallState: TargetState = .closed
        let views = playerViews
        
        for (index, player) in players.enumerated() {
            let hits = player.hits(for: target, upTo: round)
            let state = game.state(for: target, player: player, round: round)
            
            let view = views[index]
            view.hits = hits
            state.apply(view: view)
            
            if state != .closed {
                overallState = .initial
            }
        }
        
        return overallState
    }
    
}

class CricketHeaderCellView: UITableViewCell {
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel?
    @IBOutlet weak var player3Label: UILabel?
    @IBOutlet weak var player4Label: UILabel?
    @IBOutlet weak var player5Label: UILabel?
    @IBOutlet weak var player6Label: UILabel?
    
    @IBOutlet weak var targetScoreLabel: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel?
    @IBOutlet weak var player3ScoreLabel: UILabel?
    @IBOutlet weak var player4ScoreLabel: UILabel?
    @IBOutlet weak var player5ScoreLabel: UILabel?
    @IBOutlet weak var player6ScoreLabel: UILabel?
    
}

extension CricketHeaderCellView {
    
    var labels: [(name: UILabel, score: UILabel)] {
        var views: [(name: UILabel, score: UILabel)] = [(name: player1Label, score: player1ScoreLabel)]
        
        if let view = player2Label {
            views.append((name: view, score: player2ScoreLabel!))
            
            if let view = player3Label {
                views.append((name: view, score: player3ScoreLabel!))
                
                if let view = player4Label {
                    views.append((name: view, score: player4ScoreLabel!))
                    
                    if let view = player5Label {
                        views.append((name: view, score: player5ScoreLabel!))
                        
                        if let view = player6Label {
                            views.append((name: view, score: player6ScoreLabel!))
                        }
                    }
                }
            }
        }
        
        return views
    }
    
    func populate(with players: [GamePlayer], game: CoreGame) {
        let views = labels
        
        for (index, player) in players.enumerated() {
            let view = views[index]
            
            let score = game.score(forPlayer: player) ?? 0
            view.score.text = "\(score)"
            view.name.text = player.name
        }
    }
    
}

fileprivate extension TargetState {
    
    func apply(view: UIView?) {
        guard let view = view else { return }
        
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
