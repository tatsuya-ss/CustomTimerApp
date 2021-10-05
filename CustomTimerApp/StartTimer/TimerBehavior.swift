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
}

final class TimerBehavior {
    
    private var customTimer: CustomTimerComponent!
    private var timer = Timer()
    private var timeIndex = 0
    weak var delegate: TimerBehaviorDelegate?
    
    init(customTimer: CustomTimerComponent) {
        self.customTimer = customTimer
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true,
                                     block: { [weak self] timer in
            
            guard let timeIndex = self?.timeIndex,
                  let timeInfomations = self?.customTimer.timeInfomations
            else { return }
            let photo = timeInfomations[timeIndex].photo
            let timeString = timeInfomations[timeIndex].time.makeTimeString()
            let isTimeUp = timeInfomations[timeIndex].time.isTimeUp
            let numberOfTimes = timeInfomations.count

            if isTimeUp {
                if timeIndex < numberOfTimes - 1 {
                    self?.timeIndex += 1
                } else {
                    timer.invalidate()
                    print("終了")
                }
            }
            
            self?.customTimer.timeInfomations[timeIndex].time.countDown()
            self?.delegate?.timerBehavior(didCountDown: timeString,
                                          with: photo)
        })
    }
    
    func makeInitialPhotoData() -> Data? {
        customTimer.timeInfomations.first?.photo
    }
    
}

