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
    
    var player: GamePlayer? {
        didSet {
            markerView?.setNeedsDisplay()
        }
    }
    var game: CoreGame? {
        didSet {
            update(forGame: game)
        }
    }
    var round: Int = 0 {
        didSet {
            dataSource?.round = round
            
            boardView?.setNeedsDisplay()
            markerView?.setNeedsDisplay()
        }
    }
    
    private var layout: BoardLayout!
    private var dataSource: BoardDataSource!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var markerView: MarkerView!
    
    // MARK: IBAction
    
    @IBAction func didTapBoard(gesture: UITapGestureRecognizer) {
        guard let game = game else { return }
        guard let player = player else { return }
        
        if let target = layout?.target(forPoint: gesture.location(in: view)) {
            game.score(player: player, target: target, round: round)
            
            markerView?.setNeedsDisplay()
        }
    }
    
    // MARK: Events
    
    func didOpenTarget(sender: Notification) {
        boardView?.setNeedsDisplay()
    }
    
    func didCloseTarget(sender: Notification) {
        boardView?.setNeedsDisplay()
    }
    
    func didGameFinish(sender: Notification) {
        boardView?.setNeedsDisplay()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markerView.dataSource = self
        
        update(forGame: game)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.didOpenTarget(sender:)), name: Notification.Name("TargetOpen"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.didCloseTarget(sender:)), name: Notification.Name("TargetClose"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BoardViewController.didGameFinish(sender:)), name: Notification.Name("GameFinished"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        view.setNeedsLayout()
    }
    
    private func update(forGame game: CoreGame?) {
        guard let game = game else { return }
        guard let player = player else { return }
        
        let layout = BoardLayout(model: game.model)
        self.layout = layout
        
        dataSource = BoardDataSource(game: game, player: player)
        
        boardView?.layout = layout
        boardView?.dataSource = dataSource
        
        markerView?.layout = layout
        
        markerView?.setNeedsDisplay()
        boardView?.setNeedsDisplay()
    }
    
}

extension BoardViewController: MarkerViewDataSource {
    
    func numberOfSections(in markerView: MarkerView) -> Int {
        return game?.model.sectionCount ?? 0
    }
    
    func boardView(_ markerView: MarkerView, maxMarksForSection section: Int) -> Int {
        return game?.throwsPerTurn ?? 0
    }
    
    func boardView(_ markerView: MarkerView, hitsForSection section: Int) -> Int {
        var marks: Int?
        if let value = game?.model.target(forIndex: section)?.value {
            marks = player?.score.totalHits(for: value)
        }
        return marks ?? 0
    }
    
    func bullsEyeMarks(in markerView: MarkerView) -> Int {
        return game?.model.targetForBullseye()?.value ?? 0
    }
    
}

extension BoardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("\(touch.location(in: view))")
        return true
    }
    
}
