//
//  GameViewController
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-19.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

fileprivate enum DoneType {
    case nextRound
    case done
    case stats
    case none
}

class GameViewController: UIPageViewController {
    
    // MARK: Variables
    
    var game: CoreGame!
    var round: Int = 0
    var currentIndex: Int = 0
    
    weak var pagingDelegate: PageViewControllerDelegate?
    
    private var doneType: DoneType = .nextRound
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        var viewControllers: [UIViewController] = []
        
        for player in self.game.players {
            viewControllers.append(self.newViewController(withIdentifier: "player", player: player))
        }
        
        let viewController = self.game.game.scoreViewController() ?? UIStoryboard(name: "Score", bundle: nil).instantiateViewController(withIdentifier: "score")
        if let scoreViewController = viewController as? ScoreView {
            scoreViewController.game = self.game
            scoreViewController.round = self.round
            viewControllers.append(viewController)
        }
        
        // The view controllers will be shown in this order
        return viewControllers
    }()
    
    // MARK: IBOutlets
    
    @IBOutlet var nextRoundBarButtonItem: UIBarButtonItem! // explicit strong reference
    @IBOutlet var doneBarButtonItem: UIBarButtonItem! // explicit strong reference
    @IBOutlet var statsBarButtonItem: UIBarButtonItem! // explicit strong reference
    
    // MARK: IBActions
    
    @IBAction func didTapNextRound(sender: UIBarButtonItem) {
        updateRound(from: round, to: bound(round: round + 1))
        
        childViewControllers.forEach {
            ($0 as? PlayerViewController)?.round = round
        }
    }
    
    @IBAction func didTapDoneGame(sender: UIBarButtonItem) {
        let _ = game?.winner()
    }
    
    // MARK: Events
    
    func didGameFinish(sender: Notification) {
        doneType = .stats
        
        updateRound()
    }
    
    func didUnhitTarget(sender: Notification) {
        doneType = .nextRound
        
        updateRound()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        title = game.name
        
        if let initialViewController = orderedViewControllers.first {
            scrollTo(viewController: initialViewController)
        }
        
        pagingDelegate?.pageViewController(self, didUpdatePageCount: orderedViewControllers.count)
        
        updateRound()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didGameFinish(sender:)), name: Notification.Name("GameFinished"), object: nil)
    }
    
    deinit {
        nextRoundBarButtonItem = nil
        doneBarButtonItem = nil
        statsBarButtonItem = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "score" {
            if let viewController = segue.destination as? ScoreViewController {
                viewController.game = game
            }
        }
    }
    
    // MARK: Private
    
    private func newViewController(withIdentifier identifier: String, player: GamePlayer) -> UIViewController {
        let viewController = UIStoryboard(name: "Game", bundle: nil).instantiateViewController(withIdentifier: identifier)
        
        if let playerViewController = viewController as? PlayerViewController {
            playerViewController.round = round
            playerViewController.player = player
            playerViewController.game = game
        }
        
        return viewController
    }
    
    private func updateRound(from fromRound: Int, to toRound: Int) {
        round = toRound
        doneType = fromRound == toRound ? .done : .nextRound
        
        updateRound()
    }
    
    private func updateRound() {
        if doneType == .nextRound, let rounds = game?.rounds, round == rounds - 1 {
            doneType = .done
        }
        
        switch doneType {
        case .nextRound:
            var canPlayNextRound: Bool?
            if let rounds = game?.rounds {
                canPlayNextRound = round < rounds - 1
            }
            navigationItem.rightBarButtonItems = [ nextRoundBarButtonItem ]
            nextRoundBarButtonItem?.isEnabled = canPlayNextRound ?? true
        case .done:
            navigationItem.rightBarButtonItems = [ doneBarButtonItem ]
        case .stats:
            navigationItem.rightBarButtonItems = [ statsBarButtonItem ]
        case .none:
            navigationItem.rightBarButtonItems = nil
        }
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
        if let visibleViewController = viewControllers?.first, let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollTo(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
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
        setViewControllers([viewController], direction: direction, animated: true, completion: { (finished) -> Void in
            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    fileprivate func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
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
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

// MARK: UIPageViewControllerDelegate

extension GameViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingViewControllers.forEach {
            if let viewController = $0 as? PlayerViewController {
                viewController.round = round
            } else if let viewController = $0 as? ScoreView {
                viewController.round = round
            }
            
            ($0 as? PageViewControllerPage)?.didBecomeActive(in: self)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

protocol PageViewControllerDelegate: class {
    
    func pageViewController(_ pageViewController: GameViewController, didUpdatePageCount count: Int)
    
    func pageViewController(_ pageViewController: GameViewController, didUpdatePageIndex index: Int)
    
}

protocol PageViewControllerPage: class {
    
    func didBecomeActive(in pageViewController: GameViewController)
    
}
