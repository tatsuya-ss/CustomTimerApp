//
//  CountDownOperationViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/30.
//

import UIKit

final class CountDownOperationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

// MARK: - instantiate
extension CountDownOperationViewController {
    
    static func instantiate() -> CountDownOperationViewController {
        guard let countDownOperationVC = UIStoryboard(name: "OperationMethod", bundle: nil).instantiateViewController(withIdentifier: String(describing: CountDownOperationViewController.self)) as? CountDownOperationViewController else { fatalError("CountDownOperationViewControllerが見つかりません。") }
        return countDownOperationVC
    }
    
}
