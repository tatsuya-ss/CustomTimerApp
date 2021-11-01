//
//  SignUpViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

final class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func SignUpButtonDidTapped(_ sender: Any) {
        
    }
    
}

extension SignUpViewController {
    static func instantiate(userUseCase: UserUseCaseProtocol = UserUseCase()) -> SignUpViewController {
        guard let signUpVC = UIStoryboard(name: "SignUp", bundle: nil)
                .instantiateViewController(withIdentifier: "SignUpViewController")
                as? SignUpViewController
        else { fatalError("SignUpViewControllerが見つかりません。") }
        signUpVC.userUseCase = userUseCase
        return signUpVC
    }
}
