//
//  FlipCardCollectionViewCell.swift
//  Memory
//
//  Desc: cell view for a single flippable game card on the game board (UICollectionView)
//

import UIKit
import Foundation

class FlipCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    static let defaultShadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
    static let matchedShadowColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
    
    weak var flipCardStore: FlipCard? // link to FlipCard store model
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.shadowColor = FlipCardCollectionViewCell.defaultShadowColor
        imageView.layer.shadowOffset = CGSize(width: -2.00, height: 2.00)
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.layer.shadowPath = UIBezierPath(roundedRect:imageView.bounds, cornerRadius:2.0).cgPath
    }
    
    // update view to reflect any model/state changes
    public func refreshCellContent() {
        
        guard let flipCard = flipCardStore else {
            return;
        }

        if flipCard.isFlipped {
            imageView.image = flipCard.faceImage
        } else {
            imageView.image = flipCard.backImage
        }
        
        if flipCard.isMatched {
            imageView.layer.shadowColor = FlipCardCollectionViewCell.matchedShadowColor
        } else {
            imageView.layer.shadowColor = FlipCardCollectionViewCell.defaultShadowColor
        }
    }
}
