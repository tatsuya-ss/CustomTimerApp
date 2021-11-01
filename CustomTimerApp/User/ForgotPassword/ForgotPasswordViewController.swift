//
//  ForgotPasswordViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/30.
//

import UIKit

final class ForgotPasswordViewController: UIViewController {

    @IBOutlet private weak var mailAddressTextField: UITextField!
    
    private var userUseCase: UserUseCaseProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction private func sendButtonDidTapped(_ sender: Any) {
        guard let email = mailAddressTextField.text else { return }
        userUseCase.sendPasswordReset(email: email) { [weak self] result in
            switch result {
            case .failure(let error):
                print("\(error)")
            case .success:
                self?.navigationController?.popViewController(animated: true)
                print("送信完了")
            }
        }
    }
    
}

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
