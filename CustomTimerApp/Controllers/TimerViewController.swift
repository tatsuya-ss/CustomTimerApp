//
//  TimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

class TimerViewController: UIViewController {
    @IBOutlet weak var timerCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addTimerButtonTapped(_ sender: Any) {
        let customTimerNavVC = CustomTimerViewController.instantiate()
        present(customTimerNavVC, animated: true, completion: nil)
    }
    
    @IBAction func settingButtonTapped(_ sender: Any) {
    }
    
}
