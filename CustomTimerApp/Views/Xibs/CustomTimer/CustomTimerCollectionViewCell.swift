//
//  CustomTimerCollectionViewCell.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/14.
//

import UIKit

final class CustomTimerCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
    }
        
    func configure(image: UIImage) {
        photoImageView.image = image
    }
    
    func selectedCell() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: -4.0,
                                    height: 4.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5
    }
    
    func unselectedCell() {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0.0,
                                    height: 0)
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
    }
    
}
