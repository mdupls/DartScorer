//
//  OpponentsViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class OpponentsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let visibleItems: Int = 3
    
    var players: [Player]? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var count: Int {
        return max(1, players?.count ?? 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlayer" {
            if let viewController = (segue.destination as? UINavigationController)?.childViewControllers.first as? PlayerChooserViewController {
                viewController.players = players
            }
        } else if segue.identifier == "players" {
            if let viewController = (segue.destination as? UINavigationController)?.childViewControllers.first as? PlayerChooserViewController {
                viewController.players = players
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        let playerCount = players?.count ?? 0
        
        if playerCount == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPlayerCell", for: indexPath)
        } else if indexPath.row < playerCount {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
            
            populate(cell: cell as? PlayerCollectionViewCell, indexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath)
            
            populate(cell: cell as? TeamCollectionViewCell, indexPath: indexPath)
        }
        
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
    
    private func size() -> CGSize {
        let dimension = view.frame.height
        
        return CGSize(width: dimension, height: dimension)
    }
    
    private func inset() -> UIEdgeInsets {
        let spacing = lineSpacing()
        let size = self.size()
        let horizontalInset = max(spacing, (view.frame.width - (size.width * CGFloat(count) + spacing * CGFloat(count - 1))) / 2)
        let verticalInset = (view.frame.height - size.height) / 2
        
        return UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
    
    private func lineSpacing() -> CGFloat {
        return 20
    }
    
    private func spacing() -> CGFloat {
        return 0
    }
    
    private func populate(cell: PlayerCollectionViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.nameLabel.text = players?[indexPath.row].name
    }
    
    private func populate(cell: TeamCollectionViewCell?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        cell.nameLabel.text = players?[indexPath.row].name
    }
    
}
