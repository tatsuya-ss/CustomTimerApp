//
//  CustomTimerAppTests.swift
//  CustomTimerAppTests
//
//  Created by 坂本龍哉 on 2021/08/18.
//

import XCTest
@testable import CustomTimerApp

final class TimeManagementTests: XCTestCase {
    
    func testCountDown_カウントダウンが正しく行われているか() {
        XCTContext.runActivity(named: "1時間の時") { _ in
            var oneHour = TimeManagement(hour: 1,
                                         minute: 0,
                                         second: 0)
            XCTContext.runActivity(named: "1秒経過") { _ in
                oneHour.countDown()
                XCTAssertEqual(oneHour.hour, 0)
                XCTAssertEqual(oneHour.minute, 59)
                XCTAssertEqual(oneHour.second, 59)
            }
            
            XCTContext.runActivity(named: "2秒経過") { _ in
                oneHour.countDown()
                XCTAssertEqual(oneHour.hour, 0)
                XCTAssertEqual(oneHour.minute, 59)
                XCTAssertEqual(oneHour.second, 58)
            }
        }
        
        XCTContext.runActivity(named: "1分の時") { _ in
            var oneMinute = TimeManagement(hour: 0,
                                           minute: 1,
                                           second: 0)
            XCTContext.runActivity(named: "1秒経過") { _ in
                oneMinute.countDown()
                XCTAssertEqual(oneMinute.hour, 0)
                XCTAssertEqual(oneMinute.minute, 0)
                XCTAssertEqual(oneMinute.second, 59)
            }
            
            XCTContext.runActivity(named: "2秒経過") { _ in
                oneMinute.countDown()
                XCTAssertEqual(oneMinute.hour, 0)
                XCTAssertEqual(oneMinute.minute, 0)
                XCTAssertEqual(oneMinute.second, 58)
            }
        }
        
        XCTContext.runActivity(named: "1秒の時") { _ in
            var oneSecond = TimeManagement(hour: 0,
                                           minute: 0,
                                           second: 1)
            XCTContext.runActivity(named: "1秒経過") { _ in
                oneSecond.countDown()
                XCTAssertEqual(oneSecond.hour, 0)
                XCTAssertEqual(oneSecond.minute, 0)
                XCTAssertEqual(oneSecond.second, 0)
            }
            
            XCTContext.runActivity(named: "2秒経過") { _ in
                oneSecond.countDown()
                XCTAssertEqual(oneSecond.hour, 0)
                XCTAssertEqual(oneSecond.minute, 0)
                XCTAssertEqual(oneSecond.second, 0)
            }
            
        }
    }
    
}


class CustomTimerAppTests: XCTestCase {
    
    func testExample() throws {
        
    }
    
}
