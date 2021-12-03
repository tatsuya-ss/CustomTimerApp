//
//  SignUpViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

extension SignUpViewController: ShowAlertProtocol { }
extension SignUpViewController: UIButtonLayoutProtocol { }
extension SignUpViewController: ChangeLayoutProtocol { }

final class SignUpViewController: UIViewController {
    
    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var signUpStackView: UIStackView!
    
    private var userUseCase: UserUseCaseProtocol!
    private let indicator = Indicator()
    private let secureButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(button: signUpButton, layout: SignUpButtonLayout())
        setupNotification()
        setuppasswordTextField()
        setupSecureButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction private func SignUpButtonDidTapped(_ sender: Any) {
        self.view.endEditing(true)
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

// MARK: - func
extension SignUpViewController {
    
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
        let signUpButtonBottomMaxY = signUpStackView.frame.maxY
        changeLayoutWhenKeyboardShow(notification: notification, positionMaxY: signUpButtonBottomMaxY)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        undoOriginalViewFrame(notification: notification)
    }
    
    private func setuppasswordTextField() {
        passwordTextField.rightView = secureButton
        passwordTextField.rightViewMode = .always
    }
    
    private func setupSecureButton() {
        secureButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        secureButton.addTarget(self,
                               action: #selector(secureButtonDidTapped),
                               for: .touchUpInside)
    }
    
    @objc private func secureButtonDidTapped() {
        if passwordTextField.isSecureTextEntry {
            secureButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            secureButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
        passwordTextField.isSecureTextEntry.toggle()
    }
    
}
// MARK: - instantiate
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
