//
//  TimerRepository.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/04.
//

import Foundation
import Firebase

enum DataBaseError: Error {
    // Firestore
    case aborted
    case alreadyExists
    case deadlineExceeded
    case notFound
    case permissionDenied
    // 共通
    case cancelled
    case unauthenticated
    case unknown
    // Storage
    case objectNotFound
    case bucketNotFound
    case projectNotFound
    case quotaExceeded
    case unauthorized
    case retryLimitExceeded
    case nonMatchingChecksum
    case downloadSizeExceeded
    case invalidArgument
}

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
        var isSuccessSaveData = false
        var isSuccessSavePhoto = false
        var dataBaseError: DataBaseError?
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dataStore.save(customTimer: dataBaseCustomTimer) { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .failure(let error):
                dataBaseError = DataBaseError(firestore: error)
                isSuccessSaveData = false
            case .success:
                isSuccessSaveData = true
            }
        }
        
        dispatchGroup.enter()
        dataStore.savePhoto(customTimer: customTimer) { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .failure(let error):
                dataBaseError = DataBaseError(storage: error)
                isSuccessSavePhoto = false
            case .success:
                isSuccessSavePhoto = true
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            switch (isSuccessSaveData, isSuccessSavePhoto) {
            case (true, true):
                completion(.success(nil))
            default:
                guard let dataBaseError = dataBaseError else {
                    completion(.failure(DataBaseError.unknown))
                    return
                }
                completion(.failure(dataBaseError))
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
    init(firestore error: Error) {
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
    
    init(storage error: Error) {
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
