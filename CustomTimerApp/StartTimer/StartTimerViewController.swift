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
    
    private var audioPlayer: AVAudioPlayer?
    private var timerBehavior: TimerBehavior!
    
    func getCustomTimer(customTimerComponent: CustomTimerComponent) {
        self.timerBehavior = TimerBehavior(
            timeManagement: TimeManagement(customTimerConponent: customTimerComponent)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModelInPresentation()
        setupTimerBehavior()
        setupAVAudioPlayer()
        setupTimerLocalNotification()
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
    
    static func instantiate() -> StartTimerViewController {
        guard let startTimerVC = UIStoryboard(name: "StartTimer", bundle: nil)
                .instantiateViewController(withIdentifier: "StartTimerViewController")
                as? StartTimerViewController
        else { fatalError("StartTimerViewControllerが見つかりません。") }
        return startTimerVC
    }

    private func setupTimerBehavior() {
        timerBehavior.delegate = self
        currentTimeLabel.text = timerBehavior.startTimeString()
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
    
    // MARK: LocalNotification
    private func setupTimerLocalNotification() {
        timerBehavior.countTimes.enumerated().forEach {
            let registerTime = timerBehavior.countTimes[0...$0.offset].reduce(0, +)
            let nextTime = $0.offset == timerBehavior.countTimes.endIndex - 1
            ? nil : timerBehavior.countTimes[$0.offset + 1]
            let photoData = timerBehavior.photoData[$0.offset]
            setTimerLocalNotification(registerTime: registerTime,
                                      nextTime: nextTime,
                                      photoData: photoData)
        }
    }
    
    private func setTimerLocalNotification(registerTime: Int,
                                           nextTime: Int?,
                                           photoData: Data?) {
        let content = makeNotificationContent(time: nextTime)
        let trigger = makeTimeIntervalNotificationTrigger(time: registerTime)
        let request = makeNotificationRequest(content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
            } else {
                print("通知設定完了")
            }
        }
    }
    
    private func makeNotificationContent(time: Int?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "CustomTimerApp"
        if let time = time { content.body = "次は\(time)秒です。" }
        else { content.body = "タイマー終了です。お疲れ様でした。" }
        return content
    }
    
    private func makeTimeIntervalNotificationTrigger(time: Int) -> UNTimeIntervalNotificationTrigger {
        UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(time),
            repeats: false
        )
    }
    
    private func makeNotificationRequest(content: UNMutableNotificationContent,
                                         trigger: UNTimeIntervalNotificationTrigger) -> UNNotificationRequest {
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content,
                                            trigger: trigger)
        return request
    }
    
}

