//
//  ShowAlertProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/30.
//

import UIKit

protocol ShowAlertProtocol {
    func showAlert(title: String, message: String?)
}

extension ShowAlertProtocol where Self: UIViewController {
    
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
