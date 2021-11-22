//
//  TimerBehavior.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/01.
//

import Foundation

protocol TimerBehaviorDelegate: AnyObject {
    func timerBehavior(didCountDown timeString: String,
                       with photoData: Data?)
    func makeSound()
    func timeIsUp()
}

final class TimerBehavior {
    
    private var timeManagement: TimeManagement!
    private var timer = Timer()
    
    weak var delegate: TimerBehaviorDelegate?
    
    init(timeManagement: TimeManagement) {
        self.timeManagement = timeManagement
    }
    
    var countTimes: [Int] {
        timeManagement.countTimes
    }
    
    var photoData: [Data?] {
        timeManagement.customTimerConponent.timeInfomations.map { $0.photo }
    }
    
    func getType(index: Int) -> TimerType {
        timeManagement.customTimerConponent.timeInfomations[index].type
    }
    
    func getTimerId () -> String {
        timeManagement.customTimerConponent.id
    }
    
    func getTimerName() -> String {
        timeManagement.customTimerConponent.name
    }
    
    func getTimeInfomations() -> [TimeInfomation] {
        timeManagement.customTimerConponent.timeInfomations
    }
    
    func makeInitialPhotoData() -> Data? {
        timeManagement.customTimerConponent.timeInfomations.first?.photo
    }
    
    func startTimeString() -> String {
        timeManagement.makeTimeString()
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] timer in
            guard let timeManagement = self?.timeManagement else { return }
            let timeString = timeManagement.makeTimeString()
            let photoData = timeManagement.customTimerConponent.timeInfomations[timeManagement.currentIndex].photo
            self?.delegate?.timerBehavior(didCountDown: timeString, with: photoData)
            if timeManagement.timeLeft == 0 { self?.delegate?.makeSound() }
            if timeManagement.isFinish() {
                timer.invalidate()
                self?.delegate?.timeIsUp()
            }
        })
    }
    
}

