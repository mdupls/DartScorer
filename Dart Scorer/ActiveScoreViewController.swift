//
//  ActiveScoreViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-01.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class ActiveScoreViewController: UIViewController {
    
    // MARK: Variables
    
    var game: CoreGame?
    var player: GamePlayer?
    var round: Int = 0 {
        didSet {
            update()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var placeIndicator: UIImageView!
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        update()
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        update()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        
        update()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Private
    
    fileprivate func update() {
        guard let game = game else { return }
        guard let player = player else { return }
        
        if let placeIndicator = placeIndicator {
            placeIndicator.isHidden = !game.isWinning(player: player)
        }
        
        if let scoreLabel = scoreLabel {
            scoreLabel.text = game.scoreTitle(player: player, round: round)
        }
    }
    
}

extension ActiveScoreViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        update()
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        
    }
    
}
