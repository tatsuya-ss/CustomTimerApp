//
//  StartTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

final class StartTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerContentsImageView: UIImageView!
    @IBOutlet private weak var CountDownView: UIView!
    @IBOutlet private weak var timerContentsNameLabel: UILabel!
    
    private var customTimer: CustomTimerComponent!
    func getCustomTimer(customTimer: CustomTimerComponent) {
        self.customTimer = customTimer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    @IBAction private func stopButtonTapped(_ sender: Any) {
    }
    
}
