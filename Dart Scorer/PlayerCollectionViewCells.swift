//
//  AddPlayerCollectionViewCell.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-03.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

class AddPlayerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1
    }
    
    override func draw(_ rect: CGRect) {
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        
        super.draw(rect)
    }
    
}

class PlayerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.backgroundColor = UIColor.lightGray
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1
    }
    
    override func draw(_ rect: CGRect) {
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        
        super.draw(rect)
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.black : UIColor.clear
        }
    }
    
}

class TeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconView: TeamIconView!
    
    var team: Team? {
        didSet {
            iconView.count = team?.players?.count ?? 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.black : UIColor.clear
        }
    }
    
}

class TeamIconView: UIView {
    
    var count: Int = 0 {
        didSet {
            if count != oldValue {
                setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawBackground(rect: rect)
        drawCells(rect: rect)
    }
    
    private func drawBackground(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.board.withAlphaComponent(0.4).cgColor)
        context.setAlpha(0.7)
        context.addEllipse(in: rect)
        context.fillPath()
    }
    
    private func drawCells(rect: CGRect) {
        let columns = Int(ceil(sqrt(Double(count))))
        let rows = count > columns ? columns : 1
        
        let diameter = rect.width / CGFloat(columns)
        
        var cursor: Int = 0
        
        let offsetY = (rect.height - CGFloat(rows) * diameter) / 2
        
        for row in 0 ..< rows {
            let y = diameter * CGFloat(row) + offsetY
            
            for column in 0 ..< columns {
                let cellRect = CGRect(x: diameter * CGFloat(column), y: y, width: diameter, height: diameter)
                
                drawCell(rect: cellRect)
                
                if cursor == count - 1 {
                    return
                }
                
                cursor += 1
            }
        }
    }
    
    private func drawCell(rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.hit.withAlphaComponent(0.2).cgColor)
        context.setAlpha(0.7)
        context.addEllipse(in: rect)
        context.fillPath()
    }
    
}

class PlayersHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var nameLabel: UILabel!
    
}
