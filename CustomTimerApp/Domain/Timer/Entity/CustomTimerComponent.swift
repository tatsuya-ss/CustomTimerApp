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
    var isSelected: Bool = false
    let id: String
}

struct TimeInfomation: Hashable {
    var time: Time
    var photo: Data?
    var text: String?
    var type: TimerType = .action
    let id: String
}

enum TimerType {
    case action
    case rest
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
