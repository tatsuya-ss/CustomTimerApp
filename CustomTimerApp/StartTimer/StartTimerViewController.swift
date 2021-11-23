//
//  StartTimerViewController.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/08/20.
//

import UIKit
import AVFoundation

// 効果音サイト
// https://soundeffect-lab.info/sound/button/

extension StartTimerViewController: ShowAlertProtocol { }

final class StartTimerViewController: UIViewController {
    
    @IBOutlet private weak var timerContentsImageView: UIImageView!
    @IBOutlet private weak var CountDownView: UIView!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    
    private var audioPlayer: AVAudioPlayer?
    private var timerBehavior: TimerBehavior!
    private let notificationCenter = UNUserNotificationCenter.current()
    private var notificationIdentifiers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupNavigation()
        setupModelInPresentation()
        setupTimerBehavior()
        setupAVAudioPlayer()
        setupTimerLocalNotification()
        timerBehavior.start()
    }
    
    @IBAction private func stopButtonTapped(_ sender: Any) {
        showStopTimerAlert()
    }
    
}

// MARK: - func
extension StartTimerViewController {
    
    private func removeNotificationRequests() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
    }
    
    private func showStopTimerAlert() {
        showTwoChoicesAlert(alertTitle: "タイマーを終了しますか？",
                            cancelMessage: "キャンセル",
                            destructiveTitle: "終了する",
                            handler: { [weak self] _ in
            self?.removeNotificationRequests()
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
                       with photoData: Data?,
                       timerType: TimerType) {
        currentTimeLabel.text = timeString
        if let photoData = photoData {
            let photoImage = UIImage(data: photoData)
            let isNotSameImage = (timerContentsImageView.image != photoImage)
            if isNotSameImage { timerContentsImageView.image = photoImage }
        } else {
            if timerType == .rest { timerContentsImageView.image = UIImage(named: "yasumi") }
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
    
    static func instantiate(customTimerComponent: CustomTimerComponent) -> StartTimerViewController {
        guard let startTimerVC = UIStoryboard(name: "StartTimer", bundle: nil)
                .instantiateViewController(withIdentifier: "StartTimerViewController")
                as? StartTimerViewController
        else { fatalError("StartTimerViewControllerが見つかりません。") }
        let timeManagement = TimeManagement(customTimerConponent: customTimerComponent)
        startTimerVC.timerBehavior = TimerBehavior(timeManagement: timeManagement)
        return startTimerVC
    }
    
    private func setupLayout() {
        CountDownView.layer.cornerRadius = 20
        CountDownView.layer.borderWidth = 1
        CountDownView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupTimerBehavior() {
        timerBehavior.delegate = self
        currentTimeLabel.text = timerBehavior.startTimeString()
        guard let photoData = timerBehavior.makeInitialPhotoData() else { return }
        timerContentsImageView.image = UIImage(data: photoData)
    }
    
    private func setupNavigation() {
        navigationItem.title = timerBehavior.getTimerName()
    }
    
    private func setupModelInPresentation() {
        // プルダウンジェスチャーによる解除を無効
        isModalInPresentation = true
    }
    
    private func setupAVAudioPlayer() {
        guard let soundFilePath = Bundle.main.path(forResource: "TimeUp",
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
            let nextIndex = ($0.offset == timerBehavior.countTimes.endIndex - 1) ? nil : $0.offset + 1
            setTimerLocalNotification(registerTime: registerTime, nextIndex: nextIndex)
        }
    }
    
    private func setTimerLocalNotification(registerTime: Int,
                                           nextIndex: Int?) {
        let content = makeNotificationContent(nextIndex: nextIndex)
        // TODO: 通知の時間が1秒ずれるのでここで修正（よくないかも知れないのでメモ）
        let adjustedRegisterTime = registerTime - 1
        let trigger = makeTimeIntervalNotificationTrigger(time: adjustedRegisterTime)
        let request = makeNotificationRequest(content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print(error)
            } else {
                print("通知設定完了")
            }
        }
    }
    
    private func makeNotificationContent(nextIndex: Int?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "CustomTimerApp"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "TimeUp.mp3"))
        guard let nextIndex = nextIndex else {
            let timerName = timerBehavior.getTimerName()
            content.body = "\(timerName)終了です。お疲れ様でした。"
            return content
        }
        let nextTime = timerBehavior.countTimes[nextIndex]
        let photoId = timerBehavior.getTimeInfomations()[nextIndex].id
        let fileName = photoId.makeJPGFileName()
        let directoryManagement = DirectoryManagement()
        let cachesDirectoryPathURL = directoryManagement.makeCacheDirectoryPathURL(fileName: fileName)
        let temporaryDirectoryPathURL = directoryManagement.makeTemporaryDirectoryPathURL(fileName: fileName)
        
        // MARK: 休憩で休憩画像がなければ
        if timerBehavior.photoData[nextIndex] == nil
            && timerBehavior.getType(index: nextIndex) == .rest {
            content.body = "休憩\(nextTime)秒です。"
            makeRestDataTotemporaryDirectory(temporaryURL: temporaryDirectoryPathURL)
        } else {
            content.body = "次は\(nextTime)秒です。"
            makeCopyOfDataTotemporaryDirectory(at: cachesDirectoryPathURL, to: temporaryDirectoryPathURL)
        }
        content.attachments = [try! UNNotificationAttachment(identifier: UUID().uuidString,
                                                             url: temporaryDirectoryPathURL,
                                                             options: nil)]
        return content
    }
    
    private func makeRestDataTotemporaryDirectory(temporaryURL: URL) {
        let data = UIImage(named: "yasumi")?.convertImageToData()
        do {
            try data?.write(to: temporaryURL)
        } catch {
            print(error, "失敗")
        }
    }
    
    private func makeCopyOfDataTotemporaryDirectory(at caches: URL, to temporary: URL) {
        do {
            try FileManager.default.copyItem(at: caches, to: temporary)
        } catch {
            print(error)
        }
    }
    
    private func makeTimeIntervalNotificationTrigger(time: Int) -> UNTimeIntervalNotificationTrigger {
        UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(time),
            repeats: false
        )
    }
    
    private func makeNotificationRequest(content: UNMutableNotificationContent,
                                         trigger: UNTimeIntervalNotificationTrigger) -> UNNotificationRequest {
        let notificationIdentifier = UUID().uuidString
        notificationIdentifiers.append(notificationIdentifier)
        let request = UNNotificationRequest(identifier: notificationIdentifier,
                                            content: content,
                                            trigger: trigger)
        return request
    }
    
}

