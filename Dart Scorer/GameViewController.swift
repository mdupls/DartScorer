//
//  PlayerBoardViewController.swift
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
    
    // MARK: IBActions
    
    @IBAction func didTapNextRound(sender: UIBarButtonItem) {
        round = game.select(round: round + 1)
        
        // Scroll to the first player.
        scroll(to: 0)
        
        childViewControllers.forEach {
            ($0 as? PlayerViewController)?.round = round
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = scrollView.frame.width
        let height = scrollView.frame.height
        
        var previousView: UIView?
        
        for (index, player) in game.players.enumerated() {
            let viewController = newViewController(withIdentifier: "board", index: index, player: player)
            
            addChildViewController(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
            scrollView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
            
            viewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            if let previousView = previousView {
                viewController.view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
            } else {
                viewController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }
            
            previousView = viewController.view
            
            addChildViewController(viewController)
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(game.players.count), height: scrollView.frame.height)
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
    
}

extension GameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / scrollView.frame.width)
        
        print("\(currentIndex)")
    }
    
}
