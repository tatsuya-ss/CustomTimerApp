//
//  StartTimerOperationViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/30.
//

import UIKit

final class StartTimerOperationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

// MARK: - instantiate
extension StartTimerOperationViewController {
    
    static func instantiate() -> StartTimerOperationViewController {
        guard let startTimerOperationVC = UIStoryboard(name: "OperationMethod", bundle: nil).instantiateViewController(withIdentifier: String(describing: StartTimerOperationViewController.self)) as? StartTimerOperationViewController else { fatalError("StartTimerOperationViewControllerが見つかりません。") }
        return startTimerOperationVC
    }
    
}
