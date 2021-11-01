//
//  UIViewController+Extension.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/14.
//

import UIKit

extension UIViewController {
    
    func showPhotosAuthorizationDeniedAlert() {
        let alert = UIAlertController(title: "写真へのアクセスを許可しますか？",
                                      message: nil,
                                      preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "設定画面へ",
                                           style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL,
                                      options: [:],
                                      completionHandler: nil)
        }
        let closeAction = UIAlertAction(title: "キャンセル",
                                        style: .cancel,
                                        handler: nil)
        [settingsAction, closeAction]
            .forEach { alert.addAction($0) }
        present(alert,
                animated: true,
                completion: nil)
    }

}
