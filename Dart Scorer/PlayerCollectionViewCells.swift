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
        let circleFrame = self.circleFrame(rect: rect)
        
        let columns = Int(ceil(sqrt(CGFloat(count))))
        let rows = count > columns ? Int(ceil(CGFloat(count) / CGFloat(columns))) : 1
        let circleDiameter = circleFrame.width / CGFloat(columns)
        let offsetY = (circleFrame.height - CGFloat(rows) * circleDiameter) / 2
        
        var cursor: Int = 0
        
        for row in 0 ..< rows {
            let y = circleFrame.minY + circleDiameter * CGFloat(row) + offsetY
            
            for column in 0 ..< columns {
                let cellRect = CGRect(x: circleFrame.minX + circleDiameter * CGFloat(column), y: y, width: circleDiameter, height: circleDiameter)
                
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
    
    private func circleFrame(rect: CGRect) -> CGRect {
        let diameter = rect.width
        let hypotenuse = sqrt(diameter * diameter + diameter * diameter)
        let outsideHypotenuse = (hypotenuse - diameter) / 2
        let outsideAdjacent = sqrt((outsideHypotenuse * outsideHypotenuse) / 2)
        
        return CGRect(x: rect.minX + outsideAdjacent, y: rect.minY + outsideAdjacent, width: rect.width - outsideAdjacent * 2, height: rect.height - outsideAdjacent * 2)
    }
    
}

class PlayersHeaderCell: UICollectionReusableView {
    
    @IBOutlet weak var nameLabel: UILabel!
    
}
