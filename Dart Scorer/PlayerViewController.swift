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
    
    var message: String {
        switch self {
        case .bust:
            return "Bust!"
        case .won:
            return "You Won!"
        }
    }
}

class PlayerViewController: UIViewController {
    
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
        }
    }
    
    weak var boardViewController: BoardViewController?
    weak var roundViewController: RoundViewController?
    weak var scoreViewController: ActiveScoreViewController?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var playerName: NameView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        let bust = (sender.userInfo?["score"] as? Score)?.bust ?? false
        
        if bust {
            displayStatus(status: .bust)
        } else {
            removeStatus()
        }
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        let bust = (sender.userInfo?["score"] as? Score)?.bust ?? false
        
        if bust {
            displayStatus(status: .bust)
        } else {
            removeStatus()
        }
    }
    
    func didGameFinish(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        displayStatus(status: .won)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.isHidden = true
        playerName.name = player?.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGameFinish(sender:)), name: Notification.Name("GameFinished"), object: nil)
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
        statusLabel?.isHidden = false
    }
    
    private func removeStatus() {
        statusLabel?.isHidden = true
    }
    
}
