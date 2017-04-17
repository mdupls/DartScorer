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
        return numberOfPlayers
    }
    
    var columns: Int {
        return 1 + numberOfTargets
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
        imageView.contentMode = .scaleAspectFill
        collectionView?.backgroundView = imageView
        
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
        
        if indexPath.row % columns == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "teamCell", for: indexPath)
            populate(cell: cell as? TeamHitScoreCellView, indexPath: indexPath)
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
        guard let game = game else { return }
        
        let player = game.players[Int(CGFloat(indexPath.row) / CGFloat(columns))]
        
        cell.label.text = player.team.playerNames
    }
    
    private func populate(cell: HitScoreCellView?, indexPath: IndexPath) {
        guard let cell = cell else { return }
        guard let game = game else { return }
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.board.withAlphaComponent(0.6) : UIColor.board.withAlphaComponent(0.8)
        
        let player = game.players[Int(CGFloat(indexPath.row) / CGFloat(columns))]
        let target = targets[(indexPath.row % columns) - 1]
        
        cell.populate(with: player, game: game, target: target, round: round)
    }
    
    private func size() -> CGSize {
        let inset = self.inset()
        let width = (view.frame.width - inset.left - inset.right) / CGFloat(columns)
        let height = (view.frame.height - inset.top - inset.bottom) / CGFloat(rows)
        
        return CGSize(width: width, height: max(90, height))
    }
    
    private func inset() -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 20, 0, 20)
    }
    
    private func lineSpacing() -> CGFloat {
        return 1
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
                let leftInset = inset?.left ?? 0
                let rightInset = inset?.right ?? 0
                let width = (frame.width - leftInset - rightInset) / CGFloat(items.count)
                let height = frame.height
                
                let font = UIFont(name: "HelveticaNeue", size: 50)
                
                for (index, item) in items.enumerated() {
                    let label = UILabel(frame: CGRect(x: leftInset + CGFloat(index) * width, y: 0, width: width, height: height))
                    
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textAlignment = .center
                    label.textColor = UIColor.white
                    label.font = font
                    label.text = item
                    
                    addSubview(label)
                    
                    label.topAnchor.constraint(equalTo: topAnchor).isActive = true
                    label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                    
                    if index == 0 {
                        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftInset).isActive = true
                    } else {
                        label.backgroundColor = index % 2 == 0 ? UIColor.black.withAlphaComponent(0.4) : UIColor.black.withAlphaComponent(0.6)
                        
                        label.leadingAnchor.constraint(equalTo: subviews[index - 1].trailingAnchor).isActive = true
                        label.widthAnchor.constraint(equalTo: subviews[index - 1].widthAnchor).isActive = true
                    }
                    
                    if index == items.count - 1 {
                        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightInset).isActive = true
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
