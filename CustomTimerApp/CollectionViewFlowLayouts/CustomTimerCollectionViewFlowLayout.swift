//
//  CustomTimerCollectionViewFlowLayout.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/16.
//

import UIKit

final class CustomTimerCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        guard let cv = collectionView else { return }
        scrollDirection = .horizontal

        let availableWidth = cv.bounds.inset(by: cv.layoutMargins).size.width
        let cellWidth = (availableWidth / 3).rounded(.down)
                
        let cellHeight = cv.layer.frame.height
        
        self.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
}
