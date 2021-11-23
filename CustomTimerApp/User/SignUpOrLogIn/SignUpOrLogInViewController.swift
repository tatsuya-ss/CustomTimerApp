//
//  SignUpOrLogInViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

extension SignUpOrLogInViewController: UIButtonLayoutProtocol { }

final class SignUpOrLogInViewController: UIViewController {

    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(button: signUpButton, layout: SignUpButtonLayout())
        setupButton(button: logInButton, layout: LogInButtonLayout())
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

// MARK: - instantiate
extension SignUpOrLogInViewController {
    
    static func instantiate() -> SignUpOrLogInViewController {
        guard let signUpOrLogInVC = UIStoryboard(name: "SignUpOrLogIn", bundle: nil)
                .instantiateViewController(withIdentifier: "SignUpOrLogInViewController")
                as? SignUpOrLogInViewController
        else { fatalError("SignUpOrLogInViewControllerが見つかりません。") }
        return signUpOrLogInVC
    }

}
