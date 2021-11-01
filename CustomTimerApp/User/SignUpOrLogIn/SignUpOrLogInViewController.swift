//
//  SignUpOrLogInViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

final class SignUpOrLogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func signUpButtonDidTapped(_ sender: Any) {
        let signUpVC = SignUpViewController.instantiate()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func logInButtonDidTapped(_ sender: Any) {
        let logInVC = LogInViewController.instantiate()
        navigationController?.pushViewController(logInVC, animated: true)
    }
    
}

extension SignUpOrLogInViewController {
    
    static func instantiate() -> SignUpOrLogInViewController {
        guard let signUpOrLogInVC = UIStoryboard(name: "SignUpOrLogIn", bundle: nil)
                .instantiateViewController(withIdentifier: "SignUpOrLogInViewController")
                as? SignUpOrLogInViewController
        else { fatalError("SignUpOrLogInViewControllerが見つかりません。") }
        return signUpOrLogInVC
    }

}
