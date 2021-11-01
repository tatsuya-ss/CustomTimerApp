//
//  ForgotPasswordViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

final class ForgotPasswordViewController: UIViewController {

    @IBOutlet private weak var mailAddressTextField: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func sendButtonDidTapped(_ sender: Any) {
        
    }
    
}

extension ForgotPasswordViewController {
    
    static func instantiate() -> ForgotPasswordViewController {
        guard let forgotPasswordVC = UIStoryboard(name: "ForgotPassword", bundle: nil)
                .instantiateViewController(withIdentifier: "ForgotPasswordViewController")
                as? ForgotPasswordViewController
        else { fatalError("ForgotPasswordViewControllerが見つかりません。") }
        return forgotPasswordVC
    }

}
