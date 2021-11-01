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
    
    private var userUseCase: UserUseCaseProtocol!
    private let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func logInButtonDidTapped(_ sender: Any) {
        guard let mail = mailAddressTextField.text,
              let password = passwordTextField.text else { return }
        indicator.show(flashType: .progress)
        userUseCase.logIn(email: mail,
                          password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    print("アラート表示 \(error)")
                }
            case .success:
                self?.indicator.flash(flashType: .success) {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction private func forgotPasswordButtonDidTapped(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordViewController.instantiate()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
}

extension LogInViewController {
    
    static func instantiate(userUseCase: UserUseCaseProtocol = UserUseCase()) -> LogInViewController {
        guard let logInVC = UIStoryboard(name: "LogIn", bundle: nil)
                .instantiateViewController(withIdentifier: "LogInViewController")
                as? LogInViewController
        else { fatalError("LogInViewControllerが見つかりません。") }
        logInVC.userUseCase = userUseCase
        return logInVC
    }

}
