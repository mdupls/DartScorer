//
//  RoundViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-22.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class RoundViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Variables
    
    var player: GamePlayer?
    var round: Int? {
        didSet {
            update()
        }
    }
    var scores: [Tracker]?
    var collectionViewTraitCollection: UITraitCollection?
    
    var count: Int {
        return scores?.count ?? 0
    }
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        update()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RoundViewController.didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        collectionViewTraitCollection = newCollection
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UITableViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "single", for: indexPath)
        
        populate(cell: cell as? ScoreCellView, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return size()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return inset()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing()
    }
    
    // MARK: Private
    
    private func update() {
        guard let round = round else { return }
        
        scores = player?.scores[round]?.scores
        
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func populate(cell: ScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.valueLabel.text = "\(scores?[indexPath.row].totalValue ?? 0)"
    }
    
    private func size() -> CGSize {
        return CGSize(width: 142, height: 180)
    }
    
    private func inset() -> UIEdgeInsets {
        let horizontal = lineSpacing()
        
        return UIEdgeInsetsMake(0, horizontal, 0, horizontal)
    }
    
    private func lineSpacing() -> CGFloat {
        let gaps = count > 0 ? (view.frame.width - CGFloat(count) * size().width) / CGFloat(count + 1) : 0
        
        return gaps
    }
    
    private func spacing() -> CGFloat {
        let orientation = UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsPortrait(orientation) {
            switch (collectionViewTraitCollection ?? collectionView!.traitCollection).horizontalSizeClass {
            case .compact:
                return 5
            default:
                return 30
            }
        } else {
            switch (collectionViewTraitCollection ?? collectionView!.traitCollection).horizontalSizeClass {
            case .compact:
                return 5
            default:
                return 42
            }
        }
    }
    
}

// MARK: UICollectionViewCell

class ScoreCellView: UICollectionViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    
}


