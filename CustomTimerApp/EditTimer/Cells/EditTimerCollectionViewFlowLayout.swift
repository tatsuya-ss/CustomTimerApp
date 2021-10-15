//
//  EditTimerCollectionViewFlowLayout.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/15.
//

import UIKit

final class EditTimerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        guard let cv = collectionView else { return }
        scrollDirection = .horizontal

        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        let cellWidth = (availableWidth / 3).rounded(.down)
                
        let cellHeight = cv.layer.frame.height * 0.9
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
        sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
}
