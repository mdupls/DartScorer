//
//  PlayerViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-20.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    
    // MARK: Variables
    
    var player: GamePlayer?
    var game: CoreGame?
    var round: Int = 0 {
        didSet {
            let bust = player?.score(for: round)?.bust ?? false
            
            bustLabel?.isHidden = !bust
            
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
    @IBOutlet weak var bustLabel: UILabel!
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        let bust = (sender.userInfo?["score"] as? Score)?.bust ?? false
        
        bustLabel.isHidden = !bust
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        let bust = (sender.userInfo?["score"] as? Score)?.bust ?? false
        
        bustLabel.isHidden = !bust
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bustLabel.isHidden = true
        playerName.name = player?.name
        
        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
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
    
}
