//
//  NotificationOperationViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/30.
//

import UIKit

final class NotificationOperationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

// MARK: - instantiate
extension NotificationOperationViewController {
    
    static func instantiate() -> NotificationOperationViewController {
        guard let notificationOperationVC = UIStoryboard(name: "OperationMethod", bundle: nil).instantiateViewController(withIdentifier: String(describing: NotificationOperationViewController.self)) as? NotificationOperationViewController else { fatalError("NotificationOperationViewControllerが見つかりません。") }
        return notificationOperationVC
    }
    
}
