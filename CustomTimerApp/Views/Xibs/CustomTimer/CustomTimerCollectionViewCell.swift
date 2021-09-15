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
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    func configure(image: UIImage) {
        photoImageView.image = image
    }
    
}