//
//  CustomTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

class CustomTimerViewController: UIViewController {
    @IBOutlet private weak var timerNameTextField: UITextField!
    @IBOutlet private weak var TimerContentsCollectionView: UICollectionView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func saveTimerButtonTapped(_ sender: Any) {
    }
    @IBAction private func cancelButtonTapped(_ sender: Any) {
    }
}
