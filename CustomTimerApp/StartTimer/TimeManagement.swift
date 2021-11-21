//
//  TimeManagement.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/10/06.
//

import Foundation

struct TimeManagement {
    var customTimerConponent: CustomTimerComponent
    var countTimes: [Int]{
        customTimerConponent.timeInfomations.map {
            $0.time.second + ($0.time.minute * 60) + $0.time.hour * 3600
        }
    }
    var startDate: Date = Date()
    var endDates: [Date] {
        countTimes.enumerated().map {
            let time = countTimes[0...$0.offset].reduce(0, +)
            return startDate.addingTimeInterval(TimeInterval(time))
        }
    }
    var currentIndex: Int {
        for endDate in endDates.enumerated() {
            if endDate.element > Date() {
                return endDate.offset
            }
        }
        return endDates.endIndex - 1
    }
    var timeLeft: Int {
        Int(endDates[currentIndex].timeIntervalSince1970 - Date().timeIntervalSince1970)
    }
    
    func isFinish(now: Date = Date()) -> Bool {
        return now + 1 >= endDates.last ?? Date()
    }
    
    func makeTimeString() -> String {
        if timeLeft < 1 { return "00:00:00" }
        return TimeString().makeTimeString(hour: timeLeft / 3600,
                                           minute: (timeLeft % 3600) / 60,
                                           second: (timeLeft % 3600) % 60)
    }
    
}
