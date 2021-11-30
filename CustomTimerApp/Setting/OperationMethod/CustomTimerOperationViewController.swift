//
//  CustomTimerOperationViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/30.
//

import UIKit

final class CustomTimerOperationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

// MARK: - instantiate
extension CustomTimerOperationViewController {
    
    static func instantiate() -> CustomTimerOperationViewController {
        guard let customTimerOperationVC = UIStoryboard(name: "OperationMethod", bundle: nil).instantiateViewController(withIdentifier: String(describing: CustomTimerOperationViewController.self)) as? CustomTimerOperationViewController else { fatalError("CustomTimerOperationViewControllerが見つかりません。") }
        return customTimerOperationVC
    }
    
}
