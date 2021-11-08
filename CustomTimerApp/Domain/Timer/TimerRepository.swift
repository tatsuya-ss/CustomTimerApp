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
        
        dataStore.savePhoto(customTimer: dataBaseCustomTimer) { result in
            switch result {
            case .failure(let error):
                completion(.failure(DataBaseError(error: error)))
            case .success:
                completion(.success(nil))
            }
        }
    }
    
}

// MARK: - 共通の型へ変換
private extension DataBaseCustomTimer {
    init(customTimer: CustomTimerComponent) {
        let timeInfomations = customTimer.timeInfomations
            .map { DataBaseTimeInfomation(timeInfomation: $0) }
        self = DataBaseCustomTimer(name: customTimer.name,
                                   timeInfomations: timeInfomations,
                                   id: customTimer.id.uuidString)
    }
}

private extension DataBaseTimeInfomation {
    init(timeInfomation: TimeInfomation) {
        self = DataBaseTimeInfomation(
            time: DataBaseTime(time: timeInfomation.time),
            photo: timeInfomation.photo,
            text: timeInfomation.text,
            isRest: timeInfomation.type == .rest ? true : false,
            id: timeInfomation.id.uuidString
        )
    }
}

private extension DataBaseTime {
    init(time: Time) {
        self = DataBaseTime(
            hour: time.hour,
            minute: time.minute,
            second: time.second
        )
    }
}

// MARK: - Error.init 変換
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

private extension StorageError {
    init(error: Error) {
        if let errorCode = StorageErrorCode(rawValue: error._code) {
            switch errorCode {
            case .objectNotFound: self = .objectNotFound
            case .bucketNotFound: self = .bucketNotFound
            case .projectNotFound: self = .projectNotFound
            case .quotaExceeded: self = .quotaExceeded
            case .unauthenticated: self = .unauthenticated
            case .unauthorized: self = .unauthorized
            case .retryLimitExceeded: self = .retryLimitExceeded
            case .nonMatchingChecksum: self = .nonMatchingChecksum
            case .downloadSizeExceeded: self = .downloadSizeExceeded
            case .cancelled: self = .cancelled
            case .invalidArgument: self = .invalidArgument
            default: self = .unknown
            }
        } else {
            self = .unknown
        }
    }
}
