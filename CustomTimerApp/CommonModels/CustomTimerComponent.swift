//
//  CustomTimerComponent.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/08.
//

import Foundation

struct CustomTimerComponent: Hashable {
    var name: String
    var timeInfomations: [TimeInfomation]
}

struct TimeInfomation: Hashable {
    var time: Time
    var photo: Data?
    var text: String?
}

struct Time: Hashable {
    var hour: Int
    var minute: Int
    var second: Int
    
    func makeTimeString() -> String {
        TimeString().makeTimeString(hour: hour,
                                    minute: minute,
                                    second: second)
    }
}

struct TimeManagement {
    var startDate: Date
    var time: Time
    var count: Int {
        time.second + (time.minute * 60) + (time.hour * 60 * 60)
    }
    var endDate: Date {
        startDate.addingTimeInterval(TimeInterval(count))
    }
    var timeLeft: Int {
        Int(endDate.timeIntervalSince1970 - Date().timeIntervalSince1970 + 1)
    }
    
    func isFinish(now: Date) -> Bool {
        now > endDate
    }
    
    func makeTimeString() -> String {
        return TimeString().makeTimeString(hour: timeLeft / 3600,
                                           minute: (timeLeft % 3600) / 60,
                                           second: (timeLeft % 3600) % 60)
    }
    
}
