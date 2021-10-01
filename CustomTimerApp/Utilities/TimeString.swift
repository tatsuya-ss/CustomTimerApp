//
//  TimeString.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/26.
//

import Foundation


struct TimeString {
    
    func makeTimeString(hour: Int, minute: Int, second: Int) -> String {
        let stringHour = makeTwoDigits(time: hour)
        let stringMinute = makeTwoDigits(time: minute)
        let stringSecond = makeTwoDigits(time: second)
        return "\(stringHour):\(stringMinute):\(stringSecond)"
    }
    
    private func makeTwoDigits(time: Int) -> String {
        if time < 10 {
            return "0\(time)"
        } else {
            return String(time)
        }
    }
    
}
