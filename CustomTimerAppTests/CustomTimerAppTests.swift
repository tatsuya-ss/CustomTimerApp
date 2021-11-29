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
            let testTime = Time(hour: 1, minute: 20, second: 30)
            let testTimeInfomations = [TimeInfomation(time: testTime,
                                                      id: UUID().uuidString)]
            let testCustomTimeComponent = CustomTimerComponent(
                name: "テストタイマー１",
                timeInfomations: testTimeInfomations,
                id: UUID().uuidString
            )
            let testTimeManagement = TimeManagement(
                customTimerConponent: testCustomTimeComponent
            )
            XCTAssertEqual(testTimeManagement.countTimes[0], 4830)
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
        let testTime = Time(hour: 1, minute: 20, second: 30)
        XCTContext.runActivity(named: "データがない場合") { _ in
            let testTimeInfomationsNilData = [TimeInfomation(time: testTime,
                                                             photo: nil,
                                                             id: UUID().uuidString)]
            let testCustomTimeComponentNil = CustomTimerComponent(
                name: "テストNil",
                timeInfomations: testTimeInfomationsNilData,
                id: UUID().uuidString
            )
            let timeManagement = TimeManagement(customTimerConponent: testCustomTimeComponentNil)
            let timeBehaviorNilData = TimerBehavior(timeManagement: timeManagement)
            let data = timeBehaviorNilData.makeInitialPhotoData()
            XCTAssertNil(data)
        }
        
        XCTContext.runActivity(named: "データがある場合") { _ in
            let testTimeInfomationsNotNilData = [TimeInfomation(time: testTime,
                                                                photo: Data(),
                                                                id: UUID().uuidString)]
            let testCustomTimeComponentNotNil = CustomTimerComponent(
                name: "テストNotNil",
                timeInfomations: testTimeInfomationsNotNilData,
                id: UUID().uuidString
            )
            let timeManagement = TimeManagement(customTimerConponent: testCustomTimeComponentNotNil)
            let timeBehaviorNotNilData = TimerBehavior(timeManagement: timeManagement)
            let data = timeBehaviorNotNilData.makeInitialPhotoData()
            XCTAssertNotNil(data)
        }
    }

}

class CustomTimerAppTests: XCTestCase {
    
    func testExample() throws {
        
    }
    
}
