//
//  HitScoreViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-16.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class HitScoreViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ScoreView {
    
    // MARK: Variables
    
    var game: CoreGame?
    var config: Config?
    
    var count: Int {
        return config?.targets.count ?? 0
    }
    
    var numberOfPlayers: Int {
        return game?.players.count ?? 0
    }
    
    var numberOfTargets: Int {
        return targets.count
    }
    
    var rows: Int {
        return 1 + numberOfTargets
    }
    
    var columns: Int {
        return 1 + numberOfPlayers
    }
    
    var targetIndex: Int {
        return Int(columns / 2)
    }
    
    var targets: [Int] {
        return config?.targets ?? []
    }
    
    var round: Int = 0 {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    private var collectionViewTraitCollection: UITraitCollection?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "wood3")
        let imageView = UIImageView(image: image)
        collectionView?.backgroundView = imageView
        
        collectionView?.layer.cornerRadius = 100
        collectionView?.layer.masksToBounds = true
        
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionFootersPinToVisibleBounds = true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        collectionViewTraitCollection = newCollection
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows * columns
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if row(for: indexPath) == 0 {
            if column(for: indexPath) == targetIndex {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "targetCell", for: indexPath)
                populate(cell: cell as? TargetScoreCellView, indexPath: indexPath)
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath)
                populate(cell: cell as? TeamHitScoreCellView, indexPath: indexPath)
            }
        } else if column(for: indexPath) == targetIndex {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "targetCell", for: indexPath)
            populate(cell: cell as? TargetScoreCellView, indexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            populate(cell: cell as? HitScoreCellView, indexPath: indexPath)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView
        switch kind {
        case UICollectionElementKindSectionFooter:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
        default:
            view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        }
        
        if let cell = view as? HitScoreHeaderView {
            var items: [String] = [""]
            targets.forEach { items.append("\($0)") }
            
            cell.inset = inset()
            cell.spacing = spacing()
            cell.items = items
        }
        
        return view
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if column(for: indexPath) == targetIndex {
            return CGSize(width: 80, height: size().height)
        }
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
    
    private func populate(cell: TeamHitScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        let player = self.player(for: indexPath)
        
        cell.label.text = player.team.playerNames
    }
    
    private func populate(cell: TargetScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        
        if row(for: indexPath) == 0 {
            cell.label.text = ""
        } else {
            let target = self.target(for: indexPath)
            
            cell.label.text = "\(target)"
        }
    }
    
    private func populate(cell: HitScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let game = game else { return }
        
        let player = self.player(for: indexPath)
        let target = self.target(for: indexPath)
        
        cell.populate(with: player, game: game, target: target, round: round)
    }
    
    private func player(for indexPath: IndexPath) -> GamePlayer {
        var index = column(for: indexPath)
        if index >= targetIndex {
            index -= 1
        }
        return game!.players[index]
    }
    
    private func target(for indexPath: IndexPath) -> Int {
        return targets[row(for: indexPath) - 1]
    }
    
    private func column(for indexPath: IndexPath) -> Int {
        return Int(CGFloat(indexPath.row) / CGFloat(rows))
    }
    
    private func row(for indexPath: IndexPath) -> Int {
        return indexPath.row % rows
    }
    
    private func size() -> CGSize {
        let inset = self.inset()
        let width = (view.frame.width - inset.left - inset.right - 80) / CGFloat(columns - 1)
        let height = (view.frame.height - inset.top - inset.bottom) / CGFloat(rows)
        
        return CGSize(width: max(90, width), height: height)
    }
    
    private func inset() -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 20, 40, 20)
    }
    
    private func lineSpacing() -> CGFloat {
        return 0
    }
    
    private func spacing() -> CGFloat {
        return 0
    }

}

// MARK: PageViewControllerPage

extension HitScoreViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        collectionView?.reloadData()
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        
    }
    
}

class TeamHitScoreCellView: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}

class TargetScoreCellView: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
}

class HitScoreCellView: UICollectionViewCell {
    
    @IBOutlet weak var hitView: CricketHitView!
    
}

extension HitScoreCellView {
    
    func populate(with player: GamePlayer, game: CoreGame, target: Int, round: Int) {
        let hits = player.hits(for: target, upTo: round)
        let state = game.state(for: target, player: player, round: round)
        
        hitView.hits = hits
        state.apply(view: self)
        
//        if state != .closed {
//            overallState = .initial
//        }
//        
//        return overallState
    }
    
}

class HitScoreHeaderView: UICollectionReusableView {
    
    var items: [String]? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            
            if let items = items, !items.isEmpty {
                let topInset = inset?.top ?? 0
                let bottomInset = inset?.bottom ?? 0
                let width = frame.width
                let height = (frame.height - topInset - bottomInset) / CGFloat(items.count)
                
                let font = UIFont(name: "HelveticaNeue", size: 50)
                
                for (index, item) in items.enumerated() {
                    let label = UILabel(frame: CGRect(x: 0, y: topInset + CGFloat(index) * height, width: width, height: height))
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.backgroundColor = UIColor.board
                    label.textAlignment = .center
                    label.textColor = UIColor.white
                    label.font = font
                    label.text = item
                    
                    addSubview(label)
                    
                    label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
                    label.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
                    
                    if index == 0 {
                        label.topAnchor.constraint(equalTo: topAnchor, constant: topInset).isActive = true
                    } else {
                        label.backgroundColor = index % 2 == 0 ? UIColor.black.withAlphaComponent(0.4) : UIColor.black.withAlphaComponent(0.6)
                        
                        label.topAnchor.constraint(equalTo: subviews[index - 1].bottomAnchor).isActive = true
                        label.heightAnchor.constraint(equalTo: subviews[index - 1].heightAnchor).isActive = true
                    }
                    
                    if index == items.count - 1 {
                        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomInset).isActive = true
                    }
                }
            }
        }
    }
    var inset: UIEdgeInsets?
    var spacing: CGFloat = 0
    
}

fileprivate extension TargetState {
    
    func apply(view: UIView?) {
        guard let view = view else { return }
        
        switch self {
        case .closed:
            view.alpha = 0.2
        case .initial:
            view.alpha = 1
        case .open:
            view.alpha = 1
        }
    }
    
    func apply(view: UITableViewCell) {
        switch self {
        case .closed:
            view.backgroundColor = UIColor.lightGray
        case .initial:
            view.backgroundColor = UIColor.white
        case .open:
            view.backgroundColor = UIColor.white
        }
    }
    
}
