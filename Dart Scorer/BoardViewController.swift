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
    var round: Int? {
        didSet {
            boardView?.setNeedsDisplay()
            markerView?.setNeedsDisplay()
        }
    }
    
    private var layout: BoardLayout!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var markerView: MarkerView!
    
    // MARK: IBAction
    
    @IBAction func didTapBoard(gesture: UITapGestureRecognizer) {
        guard let game = game else { return }
        guard let player = player else { return }
        guard let round = round else { return }
        
        if let target = layout?.target(forPoint: gesture.location(in: view)) {
            game.score(player: player, target: target, round: round)
            
            markerView?.setNeedsDisplay()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markerView.dataSource = self
        
        update(forGame: game)
    }
    
    private func update(forGame game: CoreGame?) {
        guard let game = game else { return }
        
        let layout = BoardLayout(model: game.model)
        self.layout = layout
        
        boardView?.layout = layout
        boardView?.dataSource = game.model
        
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
            marks = player?.score.score(forValue: value)?.totalHits
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
