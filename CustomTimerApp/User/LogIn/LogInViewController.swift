//
//  LogInViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

extension LogInViewController: ShowAlertProtocol { }
extension LogInViewController: UIButtonLayoutProtocol { }
extension LogInViewController: ChangeLayoutProtocol { }

final class LogInViewController: UIViewController {

    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var logInStackView: UIStackView!
    
    private var userUseCase: UserUseCaseProtocol!
    private let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(button: logInButton, layout: LogInButtonLayout())
        setupNotification()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction private func logInButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        guard let mail = mailAddressTextField.text,
              let password = passwordTextField.text else { return }
        indicator.show(flashType: .progress)
        userUseCase.logIn(email: mail,
                          password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    self?.showErrorAlert(title: error.errorMessage)
                    self?.view.endEditing(true)
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
    
    @IBAction private func forgotPasswordButtonDidTapped(_ sender: Any) {
        let forgotPasswordVC = ForgotPasswordViewController.instantiate()
        navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
}

// MARK: - func
extension LogInViewController {
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keybordWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keybordWillShow(notification: Notification) {
        let signUpButtonBottomMaxY = logInStackView.frame.maxY
        changeLayoutWhenKeyboardShow(notification: notification, positionMaxY: signUpButtonBottomMaxY)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        undoOriginalViewFrame(notification: notification)
    }

}
// MARK: - instantiate
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
