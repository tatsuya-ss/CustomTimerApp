//
//  ForgotPasswordViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

extension ForgotPasswordViewController: ShowAlertProtocol { }
extension ForgotPasswordViewController: UIButtonLayoutProtocol { }

final class ForgotPasswordViewController: UIViewController {

    @IBOutlet private weak var mailAddressTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    private var userUseCase: UserUseCaseProtocol!
    private let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton(button: sendButton, layout: SendButtonLayout())
    }
    
    @IBAction private func sendButtonDidTapped(_ sender: Any) {
        guard let email = mailAddressTextField.text else { return }
        indicator.show(flashType: .progress)
        userUseCase.sendPasswordReset(email: email) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.indicator.flash(flashType: .error) {
                    self?.showErrorAlert(title: error.errorMessage)
                }
            case .success:
                self?.indicator.flash(flashType: .success) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}

// MARK: - instantiate
extension ForgotPasswordViewController {
    
    static func instantiate(userUseCase: UserUseCaseProtocol = UserUseCase()) -> ForgotPasswordViewController {
        guard let forgotPasswordVC = UIStoryboard(name: "ForgotPassword", bundle: nil)
                .instantiateViewController(withIdentifier: "ForgotPasswordViewController")
                as? ForgotPasswordViewController
        else { fatalError("ForgotPasswordViewControllerが見つかりません。") }
        forgotPasswordVC.userUseCase = userUseCase
        return forgotPasswordVC
    }

}
