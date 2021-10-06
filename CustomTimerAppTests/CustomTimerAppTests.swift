//
//  CustomTimerAppTests.swift
//  CustomTimerAppTests
//
//  Created by 坂本龍哉 on 2021/08/18.
//

import XCTest
@testable import CustomTimerApp

final class TimeManagementTests: XCTestCase {
    
    func testTimeCount_時間を秒に変換が出来ているか() {
        XCTContext.runActivity(named: "1時間20分30秒の時に4830秒か") { _ in
            let timeManagement = TimeManagement(startDate: Date(),
                                                time: Time(hour: 1,
                                                           minute: 20,
                                                           second: 30))
            XCTAssertEqual(timeManagement.count, 4830)
        }
    }
    
}

final class TimeStringTests: XCTestCase {
    
    func testMakeTimeString_時間の２桁表示が出来ているか() {
        let timeString = TimeString()
        XCTContext.runActivity(named: "全部１桁の時間の場合") { _ in
            let oneDigitTime = timeString.makeTimeString(hour: 0,
                                                         minute: 1,
                                                         second: 9)
            XCTAssertEqual(oneDigitTime, "00:01:09")
        }
        
        XCTContext.runActivity(named: "全部二桁の場合") { _ in
            let twoDigitsTime = timeString.makeTimeString(hour: 10,
                                                          minute: 11,
                                                          second: 12)
            XCTAssertEqual(twoDigitsTime, "10:11:12")
        }
    }
    
}

final class TimeBehaviorTests: XCTestCase {
    
    func testMakeInitialPhotoData_1番初めにデータがある時に渡せているか() {
        let timeBehaviorNil =
        TimerBehavior(customTimer: CustomTimerComponent(name: "test1", timeInfomations: [TimeInfomation(time: Time(hour: 0, minute: 0, second: 0), photo: nil, text: nil)]))
        let timeBehaviorData =
        TimerBehavior(customTimer: CustomTimerComponent(name: "test1", timeInfomations: [TimeInfomation(time: Time(hour: 0, minute: 0, second: 0), photo: Data(), text: nil)]))

        XCTContext.runActivity(named: "データがない場合") { _ in
            let data = timeBehaviorNil.makeInitialPhotoData()
            XCTAssertNil(data)
        }

        XCTContext.runActivity(named: "データがある場合") { _ in
            let data = timeBehaviorData.makeInitialPhotoData()
            XCTAssertNotNil(data)
        }
    }

}

class CustomTimerAppTests: XCTestCase {
    
    func testExample() throws {
        
    }
    
}
