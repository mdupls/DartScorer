//
//  AddPlayerCollectionViewCell.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class AddPlayerCollectionViewCell: UICollectionViewCell {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.addEllipse(in: rect)
        ctx.setFillColor(UIColor.board.cgColor)
        ctx.fillPath()
    }
    
}

class PlayerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
}

class TeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
}
