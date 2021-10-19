//
//  InsertCellProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/18.
//

import UIKit

protocol InsertCellProtocol {
    func insertCellWithAnimation(collectionView: UICollectionView,
                                 insertIndexPath: IndexPath,
                                 deselectedIndexPath: IndexPath)
}

extension InsertCellProtocol where Self : UIViewController {
    
    func insertCellWithAnimation(collectionView: UICollectionView,
                                 insertIndexPath: IndexPath,
                                 deselectedIndexPath: IndexPath) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: [insertIndexPath])
            collectionView.reloadItems(at: [deselectedIndexPath])
        } completion: { _ in
            collectionView.scrollToItem(at: insertIndexPath,
                                             at: .centeredHorizontally,
                                             animated: true)
        }
    }
    
}
