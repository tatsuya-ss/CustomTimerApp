//
//  PlusButtonCollectionViewCell.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/15.
//

import UIKit

final class PlusButtonCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var plusImageView: UIImageView!
    
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        plusImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = layer.frame.height / 2
    }

}
