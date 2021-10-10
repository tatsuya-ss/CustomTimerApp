//
//  SettingViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

final class SettingViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
