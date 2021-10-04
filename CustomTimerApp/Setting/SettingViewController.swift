//
//  SettingViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet private weak var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
