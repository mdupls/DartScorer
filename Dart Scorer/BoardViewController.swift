//
//  BoardViewController.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-03-15.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {
    
    // MARK: Variables
    
    var game: CoreGame?
    var player: GamePlayer?
    var round: Int = 0 {
        didSet {
            guard isViewLoaded else { return }
            
            roundView?.round = round
            targetSelectionView?.round = round
            dataSource?.round = round
            
            update()
        }
    }
    
    fileprivate var layout: BoardLayout!
    private var dataSource: BoardDataSource!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var roundView: RoundView!
    @IBOutlet weak var leaderView: LeaderView!
    @IBOutlet weak var markerView: MarkerView!
    @IBOutlet weak var targetSelectionView: TargetSelectionView!
    
    // MARK: IBAction
    
    // MARK: Events
    
    func didHitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        update()
    }
    
    func didUnhitTarget(sender: Notification) {
        guard player === sender.object as? GamePlayer else { return }
        
        update()
    }
    
    func didOpenTarget(sender: Notification) {
        boardView?.setNeedsDisplay()
    }
    
    func didCloseTarget(sender: Notification) {
        boardView?.setNeedsDisplay()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leaderView.game = game
        leaderView.player = player
        
        update(for: game)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didHitTarget(sender:)), name: Notification.Name("TargetHit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnhitTarget(sender:)), name: Notification.Name("TargetUnhit"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didOpenTarget(sender:)), name: Notification.Name("TargetOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCloseTarget(sender:)), name: Notification.Name("TargetClose"), object: nil)
    }
    
    private func update(for game: CoreGame?) {
        guard let game = game else { return }
        guard let player = player else { return }
        
        let layout = BoardLayout(model: game.model)
        self.layout = layout
        
        dataSource = BoardDataSource(game: game, player: player)
        
        if let targetSelectionView = targetSelectionView {
            targetSelectionView.layout = layout
            targetSelectionView.boardView = boardView
            targetSelectionView.game = game
            targetSelectionView.player = player
            targetSelectionView.delegate = self
        }
        
        if let boardView = boardView {
            boardView.layout = layout
            boardView.dataSource = dataSource
            boardView.delegate = targetSelectionView
            boardView.setNeedsDisplay()
        }
        
        if let roundView = roundView {
            roundView.layout = layout
            roundView.round = round
        }
        
        if let leaderView = leaderView {
            leaderView.layout = layout
        }
        
        if let markerView = markerView {
            markerView.layout = layout
            
            if game.showHitMarkers {
                markerView.dataSource = self
            }
            
            markerView.setNeedsDisplay()
        }
    }
    
    fileprivate func update() {
        guard let game = game else { return }
        guard let player = player else { return }
        
        var enabled: Bool
        
        if let _ = game.winner {
            enabled = false
        } else {
            let score = player.score(for: round)
            
            enabled = !(score?.bust ?? false) && (score?.hits ?? 0) < game.throwsPerTurn
        }
        
        targetSelectionView?.isUserInteractionEnabled = enabled
        boardView?.enabled = enabled
        
        leaderView?.setNeedsDisplay()
        markerView?.setNeedsDisplay()
    }
    
}

extension BoardViewController: MarkerViewDataSource {
    
    func numberOfSections(in markerView: MarkerView) -> Int {
        return game?.model.sectionCount ?? 0
    }
    
    func boardView(_ markerView: MarkerView, maxMarksForSection section: Int) -> Int {
        return game?.targetHitsRequired ?? game?.throwsPerTurn ?? 0
    }
    
    func boardView(_ markerView: MarkerView, hitsForSection section: Int) -> Int {
        var marks: Int?
        if let value = game?.model.slice(forIndex: section)?.value {
            marks = player?.score().totalHits(for: value)
        }
        return marks ?? 0
    }
    
    func bullsEyeMarks(in markerView: MarkerView) -> Int {
        return game?.model.targetForBullseye()?.value ?? 0
    }
    
}

extension BoardViewController: TargetSelectionViewDelegate {
    
    func targetSelection(_ selection: TargetSelectionView, didHit target: Target) {
        guard let player = player else { return }
        
        game?.score(player: player, target: target, round: round)
    }
    
}

extension BoardViewController: PageViewControllerPage {
    
    func willBecomeActive(in pageViewController: GameViewController) {
        update()
    }
    
    func didBecomeActive(in pageViewController: GameViewController) {
        
    }
    
}
