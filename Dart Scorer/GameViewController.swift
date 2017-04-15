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
    
    weak var pagingDelegate: PageViewControllerDelegate?
    weak var pagingViewController: UIPageViewController?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        
        for player in self.game.players {
            viewControllers.append(self.newViewController(withIdentifier: "player", player: player))
        }
        
        let viewController = self.game.game.scoreViewController() ?? UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: "score")
        if let scoreViewController = viewController as? ScoreView {
            scoreViewController.game = self.game
            viewControllers.append(viewController)
        }
        
        // The view controllers will be shown in this order
        return viewControllers
    }()
    
    // MARK: IBOutlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: IBActions
    
    @IBAction func didPageControlChanged(sender: UIPageControl) {
        scrollToViewController(index: sender.currentPage)
    }
    
    // MARK: Events
    
    func didUnhitTarget(sender: Notification) {
        
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = game.name
        
        pageControl.numberOfPages = orderedViewControllers.count
        
        if let initialViewController = orderedViewControllers.first {
            scrollTo(viewController: initialViewController)
        }
        
        pagingDelegate?.pageViewController(self, didUpdatePageCount: orderedViewControllers.count)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "score" {
            if let viewController = segue.destination as? ScoreViewController {
                viewController.game = game
            }
        } else if segue.identifier == "page" {
            pagingViewController = segue.destination as? UIPageViewController
            pagingViewController?.dataSource = self
            pagingViewController?.delegate = self
        }
    }
    
    // MARK: Private
    
    private func newViewController(withIdentifier identifier: String, player: GamePlayer) -> UIViewController {
        let viewController = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let playerViewController = viewController as? PlayerViewController {
            playerViewController.player = player
            playerViewController.game = game
        }
        
        return viewController
    }
    
    private func bound(round: Int) -> Int {
        var boundedRound = max(0, round)
        
        if let rounds = game?.rounds {
            boundedRound = min(boundedRound, rounds - 1)
        }
        
        return boundedRound
    }
    
    // MARK: ALKJFSLKDJFKJSD
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        guard let pagingViewController = pagingViewController else { return }
        
        if let visibleViewController = pagingViewController.viewControllers?.first, let nextViewController = pageViewController(pagingViewController, viewControllerAfter: visibleViewController) {
            scrollTo(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = pagingViewController?.viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollTo(viewController: nextViewController, direction: direction)
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollTo(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        pagingViewController?.setViewControllers([viewController], direction: direction, animated: true, completion: { (finished) -> Void in
            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = pagingViewController?.viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            pageControl?.currentPage = index
            pagingDelegate?.pageViewController(self, didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension GameViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        let round = (viewController as? ScoreView)?.round ?? 0
        
        guard previousIndex >= 0 else {
            guard round > 0 else {
                return nil
            }
            (orderedViewControllers.last as? ScoreView)?.round = round - 1
            return orderedViewControllers.last
        }
        
        (orderedViewControllers[previousIndex] as? ScoreView)?.round = round
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let round = (viewController as? ScoreView)?.round ?? 0
        
        guard orderedViewControllers.count != nextIndex else {
            if let rounds = game.rounds {
                guard round < rounds - 1 else {
                    return nil
                }
            } else if let winner = game.winner {
                guard round < winner.round else {
                    return nil
                }
            }
            
            (orderedViewControllers.first as? ScoreView)?.round = round + 1
            return orderedViewControllers.first
        }
        
        (orderedViewControllers[nextIndex] as? ScoreView)?.round = round
        
        return orderedViewControllers[nextIndex]
    }
    
}

// MARK: UIPageViewControllerDelegate

extension GameViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingViewControllers.forEach {
            ($0 as? PageViewControllerPage)?.willBecomeActive(in: self)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
        
        (pagingViewController?.viewControllers?.first as? PageViewControllerPage)?.didBecomeActive(in: self)
    }
    
}

protocol PageViewControllerDelegate: class {
    
    func pageViewController(_ pageViewController: GameViewController, didUpdatePageCount count: Int)
    
    func pageViewController(_ pageViewController: GameViewController, didUpdatePageIndex index: Int)
    
}

protocol PageViewControllerPage: class {
    
    func didBecomeActive(in pageViewController: GameViewController)
    
    func willBecomeActive(in pageViewController: GameViewController)
    
}
