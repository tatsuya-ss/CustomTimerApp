//
//  CustomTimerAppTests.swift
//  CustomTimerAppTests
//
//  Created by 坂本龍哉 on 2021/08/18.
//

import XCTest
@testable import CustomTimerApp

final class TimeManagementTests: XCTestCase {
    
    
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
        TimerBehavior(customTimer: CustomTimerComponent(name: "test1",
                                                        timeInfomations:
                                                            [TimeInfomation(time: TimeManagement())]))
        let timeBehaviorData =
        TimerBehavior(customTimer: CustomTimerComponent(name: "test1",
                                                        timeInfomations:
                                                            [TimeInfomation(time: TimeManagement(),
                                                                           photo: Data())]))

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
