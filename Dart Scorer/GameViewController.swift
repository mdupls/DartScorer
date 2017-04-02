//
//  GameViewController
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-19.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: Variables
    
    var game: CoreGame!
    var round: Int = 0
    var currentIndex: Int = 0
    
    // MARK: IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextRoundBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: IBActions
    
    @IBAction func didTapNextRound(sender: UIBarButtonItem) {
        round = game.select(round: round + 1)
        updateForRound()
        
        // Scroll to the first player.
        scroll(to: 0)
        
        childViewControllers.forEach {
            ($0 as? PlayerViewController)?.round = round
        }
    }
    
    // MARK: Events
    
    func didGameFinish(sender: Notification) {
        nextRoundBarButtonItem?.isEnabled = false
        
        performSegue(withIdentifier: "gameEnded", sender: nil)
    }
    
    func didUnhitTarget(sender: Notification) {
        updateForRound()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = game.name
        pageControl.numberOfPages = game.players.count
        
        scrollView.canCancelContentTouches = false
        
        let contentView = scrollView.subviews[0]
        
        for (index, player) in game.players.enumerated() {
            let viewController = newViewController(withIdentifier: "board", index: index, player: player)
            
            addChildViewController(viewController)
            contentView.addSubview(viewController.view)
            
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            if index == 0 {
                viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            } else {
                viewController.view.leadingAnchor.constraint(equalTo: childViewControllers[index - 1].view.trailingAnchor).isActive = true
            }
            
            if index == game.players.count - 1 {
                viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            }
            
            viewController.didMove(toParentViewController: self)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGameFinish(sender:)), name: Notification.Name("GameFinished"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        scroll(to: currentIndex)
    }
    
    // MARK: Private
    
    private func newViewController(withIdentifier identifier: String, index: Int, player: GamePlayer) -> UIViewController {
        let viewController = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let playerViewController = viewController as? PlayerViewController {
            playerViewController.round = round
            playerViewController.player = player
            playerViewController.game = game
        }
        
        return viewController
    }
    
    private func scroll(to index: Int) {
        currentIndex = index
        
        scrollView.contentOffset = CGPoint(x: CGFloat(index) * scrollView.frame.width, y: 0)
    }
    
    private func updateForRound() {
        var canPlayNextRound: Bool?
        if let rounds = game?.rounds {
            canPlayNextRound = round < rounds - 1
        }
        
        nextRoundBarButtonItem?.isEnabled = canPlayNextRound ?? true
    }
    
}

extension GameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating {
            currentIndex = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollView.frame.width)
            
            pageControl.currentPage = currentIndex
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("\(currentIndex)")
    }
    
}
