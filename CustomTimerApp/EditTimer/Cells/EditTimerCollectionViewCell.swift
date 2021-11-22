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
                   timeString: String = "00:00:00",
                   contentMode: ContentMode, cellState: SelectCellState) {
        photoImageView.image = image
        timeLabel.text = timeString
        photoImageView.contentMode = contentMode
        layer.masksToBounds = false
        layer.shadowOffset = cellState.shadowOffset
        layer.shadowOpacity = cellState.shadowOpacity
        layer.shadowRadius = cellState.shadowRadius
    }
    
}
