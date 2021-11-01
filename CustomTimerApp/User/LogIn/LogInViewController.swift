//
//  LogInViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

final class LogInViewController: UIViewController {

    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func logInButtonDidTapped(_ sender: Any) {
        
    }
    @IBAction private func forgotPasswordButtonDidTapped(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordViewController.instantiate()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
}

extension LogInViewController {
    
    static func instantiate() -> LogInViewController {
        guard let logInVC = UIStoryboard(name: "LogIn", bundle: nil)
                .instantiateViewController(withIdentifier: "LogInViewController")
                as? LogInViewController
        else { fatalError("LogInViewControllerが見つかりません。") }
        return logInVC
    }

}
