//
//  StartTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit
import AVFoundation

extension StartTimerViewController: ShowAlertProtocol { }

final class StartTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerContentsImageView: UIImageView!
    @IBOutlet private weak var CountDownView: UIView!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    
    private var timerBehavior: TimerBehavior!
    func getCustomTimer(customTimer: CustomTimerComponent) {
        self.timerBehavior = TimerBehavior(customTimer: customTimer)
    }
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModelInPresentation()
        setupTimerBehavior()
        setupAVAudioPlayer()
        timerBehavior.start()
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        showStopTimerAlert()
    }
    
    private func showStopTimerAlert() {
        showTwoChoicesAlert(alertTitle: "タイマーを終了しますか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "終了する",
                            handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func showTimeIsUpAlert() {
        showAlert(title: "タイマーを閉じます",
                  defaultTitle: "閉じる") { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
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
    
    func makeSound() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    func timeIsUp() {
        showTimeIsUpAlert()
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
    
    private func setupAVAudioPlayer() {
        guard let soundFilePath = Bundle.main.path(forResource: "BellSound",
                                                   ofType: "mp3")
        else { return }
        let soundURL = URL(fileURLWithPath: soundFilePath)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print(error)
        }
        audioPlayer?.prepareToPlay()
    }
    
}

