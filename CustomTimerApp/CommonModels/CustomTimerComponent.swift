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
        let hour = makeTwoDigitsString(time: hour)
        let minute = makeTwoDigitsString(time: minute)
        let second = makeTwoDigitsString(time: second)
        return hour + ":" + minute + ":" + second
    }
    
    private func makeTwoDigitsString(time: Int) -> String {
        if time < 10 {
            return "0\(time)"
        } else {
            return String(time)
        }
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
        let leftHour = timeLeft / 3600
        let letfMinute = (timeLeft % 3600) / 60
        let leftSecond = (timeLeft % 3600) % 60
        
        let hourString = makeTwoDigitsString(time: leftHour)
        let minuteString = makeTwoDigitsString(time: letfMinute)
        let secondString = makeTwoDigitsString(time: leftSecond)
        return hourString + ":" + minuteString + ":" + secondString
    }
    
    private func makeTwoDigitsString(time: Int) -> String {
        if time < 10 {
            return "0\(time)"
        } else {
            return String(time)
        }
    }
}
