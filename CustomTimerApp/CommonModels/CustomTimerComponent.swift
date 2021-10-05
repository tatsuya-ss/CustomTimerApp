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
    var time: TimeManagement
    var photo: Data?
    var text: String?
}

struct TimeManagement: Hashable {
    var hour: Int
    var minute: Int
    var second: Int
    
    var isTimeUp: Bool {
        hour == 0 && minute == 0 && second == 0
    }
    
    init(hour: Int = 0,
         minute: Int = 0,
         second: Int = 0) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }
    
    mutating func changeHour(hour: Int) {
        self.hour = hour
    }
    
    mutating func changeMinute(minute: Int) {
        self.minute = minute
    }
    
    mutating func changeSecond(second: Int) {
        self.second = second
    }
    
    func makeTimeString() -> String {
        let timeString = TimeString()
        return timeString.makeTimeString(hour: hour,
                                         minute: minute,
                                         second: second)
    }
    
    func printTimeString() {
        print("\(hour)時間\(minute)分\(second)秒")
    }
    
    mutating func countDown() {
        if second > 0 {
            second -= 1
        } else {
            if minute > 0 {
                minute -= 1
                second = 59
            } else {
                if hour > 0 {
                    hour -= 1
                    minute = 59
                    second = 59
                } else {
                    print("タイムアップ")
                }
            }
        }
    }
    
}
