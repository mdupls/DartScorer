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
    
}

class TeamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView1.layer.cornerRadius = frame.size.width / 2
        imageView1.layer.borderColor = UIColor.gray.cgColor
        imageView1.layer.borderWidth = 1
        
        imageView2.layer.cornerRadius = frame.size.width / 2
        imageView2.layer.borderColor = UIColor.gray.cgColor
        imageView2.layer.borderWidth = 1
        
        imageView3.layer.cornerRadius = frame.size.width / 2
        imageView3.layer.borderColor = UIColor.gray.cgColor
        imageView3.layer.borderWidth = 1
        
        imageView4.layer.cornerRadius = frame.size.width / 2
        imageView4.layer.borderColor = UIColor.gray.cgColor
        imageView4.layer.borderWidth = 1
    }
    
}
