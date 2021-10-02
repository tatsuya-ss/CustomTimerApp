//
//  StartTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit

extension StartTimerViewController: ShowDismissAlertProtocol { }

final class StartTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerContentsImageView: UIImageView!
    @IBOutlet private weak var CountDownView: UIView!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    
    private var timerBehavior: TimerBehavior!
    func getCustomTimer(customTimer: CustomTimerComponent) {
        self.timerBehavior = TimerBehavior(customTimer: customTimer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModelInPresentation()
        setupTimerBehavior()
        timerBehavior.start()
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        showStopTimerAlert()
    }
    
    private func showStopTimerAlert() {
        showDismissAlert(alertTitle: "タイマーを終了しますか？",
                         destructiveTitle: "終了する")
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension StartTimerViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        showStopTimerAlert()
    }
    
}

// MARK: - TimerBehaviorDelegate
extension StartTimerViewController: TimerBehaviorDelegate {
    
    func timerBehavior(didCountDown timeString: String,
                       with photoData: Data?) {
        currentTimeLabel.text = timeString
        if let photoData = photoData {
            let photoImage = UIImage(data: photoData)
            if timerContentsImageView.image != photoImage {
                timerContentsImageView.image = photoImage
            }
        }
    }
    
}

// MARK: - setup
extension StartTimerViewController {
    
    private func setupTimerBehavior() {
        timerBehavior.delegate = self
        currentTimeLabel.text = "スタート"
        guard let photoData = timerBehavior.makeInitialPhotoData()
        else { return }
        let photoImage = UIImage(data: photoData)
        timerContentsImageView.image = photoImage
    }
    
    private func setupModelInPresentation() {
        // プルダウンジェスチャーによる解除を無効
        isModalInPresentation = true
    }
    
}

