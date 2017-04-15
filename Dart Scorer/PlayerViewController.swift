//
//  PlayerViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-20.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

enum StatusMessage {
    case bust
    case won
    case lost
    case none
    
    var message: String? {
        switch self {
        case .bust:
            return "Bust!"
        case .won:
            return "You Won!"
        case .lost:
            return "You lost"
        default:
            return nil
        }
    }
}

class PlayerViewController: UIViewController, ScoreView {
    
    // MARK: Variables
    
    var player: GamePlayer?
    var game: CoreGame?
    var round: Int = 0 {
        didSet {
            let bust = player?.score(for: round)?.bust ?? false
            
            statusLabel?.isHidden = !bust
            
            boardViewController?.round = round
            roundViewController?.round = round
            scoreViewController?.round = round
            
            playerName?.name = player?.player(for: round)?.name
        }
    }
    
    weak var boardViewController: BoardViewController?
    weak var roundViewController: RoundViewController?
    weak var scoreViewController: ActiveScoreViewController?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var playerName: NameView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var gradientBackgroundView: GradientView!
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        updateStatus()
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        updateStatus()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientBackgroundView.startColor = UIColor.board.withAlphaComponent(0.5)
        gradientBackgroundView.endColor = UIColor.clear
        
        statusLabel.isHidden = true
        playerName.name = player?.player(for: round)?.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
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
            roundViewController?.game = game
            roundViewController?.round = round
        } else if segue.identifier == "score" {
            scoreViewController = segue.destination as? ActiveScoreViewController
            scoreViewController?.player = player
            scoreViewController?.game = game
            scoreViewController?.round = round
        }
    }
    
    // MARK: Private
    
    private func displayStatus(status: StatusMessage) {
        statusLabel?.text = status.message
        statusLabel?.isHidden = status == .none
    }
    
    fileprivate func updateStatus() {
        var status: StatusMessage
        if let winner = game?.winner {
            if player === winner.player {
                status = .won
            } else {
                status = .lost
            }
        } else {
            let bust = player?.score(for: round)?.bust ?? false
            
            status = bust ? .bust : .none
        }
        displayStatus(status: status)
    }
    
}

extension PlayerViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        updateStatus()
        
        scoreViewController?.willBecomeActive(in: pageViewController)
        boardViewController?.willBecomeActive(in: pageViewController)
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        scoreViewController?.didBecomeActive(in: pageViewController)
        boardViewController?.didBecomeActive(in: pageViewController)
    }
    
}
