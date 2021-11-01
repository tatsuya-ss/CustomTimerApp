//
//  ShowAlertProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/30.
//

import UIKit

protocol ShowAlertProtocol {
    func showErrorAlert(title: String)
    func showAlert(title: String,
                   message: String?,
                   defaultTitle: String,
                   handler: ((UIAlertAction) -> Void)?)
    
    func showTwoChoicesAlert(alertTitle: String,
                          cancelMessage: String,
                             destructiveTitle: String,
                             handler: ((UIAlertAction) -> Void)?)
}

extension ShowAlertProtocol where Self: UIViewController {
    
    func showErrorAlert(title: String) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }

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
    
    func showTwoChoicesAlert(alertTitle: String,
                             cancelMessage: String,
                             destructiveTitle: String,
                             handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: alertTitle,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelMessage,
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: destructiveTitle,
                                      style: .destructive,
                                      handler: handler))
        present(alert, animated: true, completion: nil)
    }
    
}
