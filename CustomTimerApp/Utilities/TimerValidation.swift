//
//  TimerValidation.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/15.
//

import Foundation

struct TimerValidation {
    let customTimer: CustomTimerComponent
    
    func validateAndReturnErrorOnFailure() -> String? {
        guard customTimer.checkTimerIsNotNil() else {
            return "保存するタイマーがありません。"
        }
        guard customTimer.checkTimeIsNotZero() else {
            return "0秒のタイマーは保存できません。"
        }
        return nil
    }
}

// MARK: - extension CustomTimerComponent
private extension CustomTimerComponent {
    
    func checkTimerIsNotNil() -> Bool {
        !timeInfomations.isEmpty
    }

    func checkTimeIsNotZero() -> Bool {
        return timeInfomations.allSatisfy {
            $0.time.hour != 0 && $0.time.minute != 0 && $0.time.second != 0
        }
    }
    
}
