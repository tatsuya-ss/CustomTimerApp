//
//  ShowAlertProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/30.
//

import UIKit

protocol ShowAlertProtocol {
    func showAlert(title: String,
                   message: String?,
                   defaultTitle: String,
                   handler: ((UIAlertAction) -> Void)?)
}

extension ShowAlertProtocol where Self: UIViewController {
    
    func showAlert(title: String,
                   message: String? = nil,
                   defaultTitle: String,
                   handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: defaultTitle,
                                      style: .default,
                                      handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
}

protocol ShowDismissAlertProtocol {
    func showDismissAlert(alertTitle: String,
                          cancelMessage: String,
                          destructiveTitle: String)
}

extension ShowDismissAlertProtocol where Self: UIViewController {
    
    func showDismissAlert(alertTitle: String,
                          cancelMessage: String = "キャンセル",
                          destructiveTitle: String) {
        let alert = UIAlertController(title: alertTitle,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelMessage,
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: destructiveTitle,
                                      style: .destructive,
                                      handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

}
