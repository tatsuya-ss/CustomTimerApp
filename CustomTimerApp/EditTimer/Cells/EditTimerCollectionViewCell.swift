//
//  EditTimerCollectionViewCell.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/15.
//

import UIKit

final class EditTimerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 10
        timeLabel.layer.cornerRadius = 10
        timeLabel.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
        
    func configure(image: UIImage?,
                   timeString: String = "00:00:00") {
        photoImageView.image = image
        timeLabel.text = timeString
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