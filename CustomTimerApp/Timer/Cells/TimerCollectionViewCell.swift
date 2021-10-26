//
//  TimerCollectionViewCell.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/08.
//

import UIKit

final class TimerCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var contentsImageView: UIImageView!
    @IBOutlet private weak var timerNameLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(timerName: String,
                   image: UIImage?,
                   isHidden: Bool) {
        timerNameLabel.text = timerName
        contentsImageView.image = image
        checkImageView.isHidden = isHidden
    }

}
