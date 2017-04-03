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
    
    var game: CoreGame?
    var player: GamePlayer?
    
    var round: Int? {
        didSet {
            update()
        }
    }
    
    private var collectionViewTraitCollection: UITraitCollection?
    
    private var targets: [Target]? {
        guard let round = round else { return nil }
        
        return player?.scores[round]?.targets
    }

    private var count: Int {
        var count: Int?
        if let round = round {
            count = player?.scores[round]?.hits
        }
        return count ?? 0
    }
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        let indexPaths = collectionView?.indexPathsForVisibleItems
        
        self.collectionView?.insertItems(at: [IndexPath(item: self.count - 1, section: 0)])
        
        if let indexPaths = indexPaths {
            for indexPath in indexPaths {
                populate(cell: collectionView?.cellForItem(at: indexPath) as? HitCellView, indexPath: indexPath)
            }
        }
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        guard let index = sender.userInfo?["index"] as? Int else { return }
        
        collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
        
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                populate(cell: collectionView?.cellForItem(at: indexPath) as? HitCellView, indexPath: indexPath)
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update(with: traitCollection)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        collectionViewTraitCollection = newCollection
        
        update(with: newCollection)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let round = round else { return }
        guard let player = player else { return }
        
        game?.undoScore(player: player, target: indexPath.row, round: round)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "single", for: indexPath)
        
        populate(cell: cell as? HitCellView, indexPath: indexPath)
        
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
        collectionView?.reloadData()
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func update(with traitCollection: UITraitCollection) {
        
    }
    
    private func populate(cell: HitCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let targets = targets else { return }
        
        let target = targets[indexPath.row]
        
        cell.target = target
        
        if game?.showHitMarkers ?? false {
            cell.hits = player?.score().totalHits(for: target.value)
            cell.requiredHits = game?.targetHitsRequired
        }
    }
    
    private func size() -> CGSize {
        let throwsPerTurn = CGFloat(game?.throwsPerTurn ?? 0)
        let width = view.frame.width / (throwsPerTurn + 1)
        
        var dimension: CGFloat
        if width < view.frame.height {
            dimension = width
        } else {
            dimension = view.frame.height / (throwsPerTurn + 1)
        }
        
        return CGSize(width: dimension, height: view.frame.height)
    }
    
    private func inset() -> UIEdgeInsets {
        let spacing = lineSpacing()
        let width = size().width
        let inset = (view.frame.width - (width * CGFloat(count) + spacing * CGFloat(count - 1))) / 2
        
        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
    
    private func lineSpacing() -> CGFloat {
        return count > 0 ? size().width / CGFloat((game?.throwsPerTurn ?? 0) + 1) : 0
    }
    
    private func spacing() -> CGFloat {
        return 0
    }
    
}
