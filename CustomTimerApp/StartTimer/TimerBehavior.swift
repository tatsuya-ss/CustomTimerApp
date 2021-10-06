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
}

final class TimerBehavior {
    
    private var customTimer: CustomTimerComponent!
    private var timer = Timer()
    private var timeIndex = 0
    private var startDate = Date()
    
    weak var delegate: TimerBehaviorDelegate?
    
    init(customTimer: CustomTimerComponent) {
        self.customTimer = customTimer
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] timer in
            guard let startDate = self?.startDate,
                  let timeIndex = self?.timeIndex,
                  let timeInfomations = self?.customTimer.timeInfomations
            else { return }
            let timeManagement = TimeManagement(startDate: startDate,
                                                time: timeInfomations[timeIndex].time)
            let isFinish = timeManagement.isFinish(now: Date())
            let numberOfTimes = timeInfomations.count
            
            if isFinish {
                self?.delegate?.makeSound()
                if timeIndex < numberOfTimes - 1 {
                    self?.timeIndex += 1
                    self?.startDate = Date()
                } else {
                    timer.invalidate()
                }
            }
            
            let timeString = timeManagement.makeTimeString()
            let photoData = timeInfomations[timeIndex].photo
            self?.delegate?.timerBehavior(didCountDown: timeString, with: photoData)
        })
    }
    
    func makeInitialPhotoData() -> Data? {
        customTimer.timeInfomations.first?.photo
    }
    
}

