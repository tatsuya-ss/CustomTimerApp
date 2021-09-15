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
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configure(timerName: String) {
        timerNameLabel.text = timerName
    }

}