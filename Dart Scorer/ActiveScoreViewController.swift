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
    @IBOutlet weak var scoreBackground: UIView!
    
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
        
        scoreBackground.layer.cornerRadius = 8
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        
        update()
    }
    
    // MARK: Private
    
    private func update() {
        guard let player = player else { return }
        
        scoreLabel?.text = game?.score(forPlayer: player, round: round)
    }
    
}
