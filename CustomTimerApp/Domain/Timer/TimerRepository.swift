//
//  TimerRepository.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/04.
//

import Foundation
import Firebase

protocol TimerRepositoryProtocol {
    func save(customTimer: CustomTimerComponent,
              completion: @escaping (Result<Any?, DataBaseError>) -> Void)
}

final class TimerRepository: TimerRepositoryProtocol {
    
    private let dataStore: TimerDataStoreProtocol
    
    init(dataStore: TimerDataStoreProtocol = TimerDataStore()) {
        self.dataStore = dataStore
    }
    
    func save(customTimer: CustomTimerComponent,
              completion: @escaping (Result<Any?, DataBaseError>) -> Void) {
        let dataBaseCustomTimer = DataBaseCustomTimer(customTimer: customTimer)
                  dataStore.save(customTimer: dataBaseCustomTimer) { result in
                      switch result {
                      case .failure(let error):
                          completion(.failure(DataBaseError(error: error)))
                      case .success:
                          completion(.success(nil))
                      }
                  }
    }
    
}

private extension DataBaseCustomTimer {
    init(customTimer: CustomTimerComponent) {
        let timeInfomations = customTimer.timeInfomations
            .map { DataBaseTimeInfomation(timeInfomation: $0) }
        self = DataBaseCustomTimer(name: customTimer.name,
                                   timeInfomations: timeInfomations)
    }
}

private extension DataBaseTimeInfomation {
    init(timeInfomation: TimeInfomation) {
        self = DataBaseTimeInfomation(time: DataBaseTime(time: timeInfomation.time),
                                      text: timeInfomation.text,
                                      isRest: timeInfomation.type == .rest ? true : false)
    }
}

private extension DataBaseTime {
    init(time: Time) {
        self = DataBaseTime(hour: time.hour,
                            minute: time.minute,
                            second: time.second)
    }
}

private extension DataBaseError {
    init(error: Error) {
        if let errorCode = FirestoreErrorCode(rawValue: error._code) {
            switch errorCode {
            case .aborted: self = .aborted
            case .alreadyExists: self = .alreadyExists
            case .cancelled: self = .cancelled
            case .deadlineExceeded: self = .deadlineExceeded
            case .notFound: self = .notFound
            case .permissionDenied: self = .permissionDenied
            case .unauthenticated: self = .unauthenticated
            default: self = .unknown
            }
        } else {
            self = .unknown
        }
    }
}
