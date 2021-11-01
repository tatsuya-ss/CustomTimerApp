//
//  SignUpViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

extension SignUpViewController: ShowAlertProtocol { }

final class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var userUseCase: UserUseCaseProtocol!
    private let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func SignUpButtonDidTapped(_ sender: Any) {
        guard let email = mailAddressTextField.text,
              let password = passwordTextField.text else { return }
        indicator.show(flashType: .progress)
        userUseCase.signUp(email: email, password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    self?.showErrorAlert(title: error.errorMessage)
                }
            case .success:
                self?.indicator.flash(flashType: .success) {
                    let timerVC = TimerViewController.instantiate()
                    let navigationVC = UINavigationController(rootViewController: timerVC)
                    navigationVC.modalPresentationStyle = .fullScreen
                    self?.present(navigationVC, animated: true, completion: nil)
                }
            }
        }
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
