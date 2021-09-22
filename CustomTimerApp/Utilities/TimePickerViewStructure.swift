//
//  TimeStructure.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/21.
//

import Foundation

protocol TimePickerViewStructure {
    var timeRange: [Int] { get }
    var unit: String { get }
    var row: Int { get }
}

struct Hour: TimePickerViewStructure {
    var timeRange: [Int] = [Int](0...23)
    var unit: String = "時間"
    var row: Int = 0
}

struct Minute: TimePickerViewStructure {
    var timeRange: [Int] = [Int](0...59)
    var unit: String = "分"
    var row: Int = 1
}

struct Second: TimePickerViewStructure {
    var timeRange: [Int] = [Int](0...59)
    var unit: String = "秒"
    var row: Int = 2
}
