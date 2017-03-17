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
    
    private let layout = BoardLayout()
    private let model = BoardModel()
    private let parser = GameParser(name: "cricket")
    private var game: IGame?
    
    private var coordinateSystem: BoardCoordinateSystem?
    
    // MARK: IBAction
    
    @IBAction func didTapBoard(gesture: UITapGestureRecognizer) {
        if let target = coordinateSystem?.target(forPoint: gesture.location(in: view), model: model) {
            if let game = game {
                game.score(player: game.currentPlayer, target: target)
            }
        }
    }
    
    // MARK: Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let player1 = Player(name: "Michael")
        let player2 = Player(name: "Tegan")
        
        var players: [Player] = []
        players.append(player1)
        players.append(player2)
        game = GameFactory().createGame(players: players)
        game?.start()
        
        coordinateSystem = BoardCoordinateSystem(layout: layout)
        
        parser.setup(model: model)
        
        let width: CGFloat = view.bounds.width
        let height: CGFloat = view.bounds.height
        
        layout.width = width
        layout.height = height
        
        let outer = layout.outer()
        outer.fillColor = UIColor(hex: 0x292821).cgColor
        view.layer.addSublayer(outer)
        
        let bullseye = layout.bullseye()
        bullseye.fillColor = UIColor(hex: 0x00984D).cgColor
        model.bullseye(section: .Single)!.apply(layer: bullseye)
        view.layer.addSublayer(bullseye)
        
        let doubleBullseye = layout.doubleBullseye()
        doubleBullseye.fillColor = UIColor(hex: 0xFF1857).cgColor
        model.bullseye(section: .Double)!.apply(layer: doubleBullseye)
        view.layer.addSublayer(doubleBullseye)
        
        let sweep = model.sweepAngle
        
        for i in 0..<model.sectionCount {
            let angle = model.angle(forIndex: i)
            
            if let target = model.slice(forIndex: i, section: .Single) {
                let pie = layout.pie(startAngle: angle, sweep: sweep)
                pie.fillColor = UIColor(hex: i % 2 == 1 ? 0xF6E0A1 : 0x292821).cgColor
                target.apply(layer: pie)
                view.layer.addSublayer(pie)
                
                let number = layout.number(startAngle: angle, sweep: sweep, number: target.value)
                number.textColor = UIColor(hex: 0xF0FBF0)
                target.apply(view: number)
                view.addSubview(number)
            }
            
            if let target = model.slice(forIndex: i, section: .Double) {
                let double = layout.double(startAngle: angle, sweep: sweep)
                double.fillColor = UIColor(hex: i % 2 == 1 ? 0x00984D : 0xFF1857).cgColor
                target.apply(layer: double)
                view.layer.addSublayer(double)
            }
            
            if let target = model.slice(forIndex: i, section: .Triple) {
                let triple = layout.triple(startAngle: angle, sweep: sweep)
                triple.fillColor = UIColor(hex: i % 2 == 1 ? 0x00984D : 0xFF1857).cgColor
                target.apply(layer: triple)
                view.layer.addSublayer(triple)
            }
        }
    }
    
}

extension Target {
    
    func apply(view: UIView) {
        view.alpha = enabled ? 1 : 0.1
    }
    
    func apply(layer: CALayer) {
        layer.opacity = enabled ? 1 : 0.1
    }
    
}
