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
    func fetch(completion: @escaping (Result<[CustomTimerComponent], DataBaseError>) -> Void)
    func delete(customTimer: [CustomTimerComponent], completion: @escaping (Result<Any?, DataBaseError>) -> Void)
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
        dataStore.saveData(customTimer: dataBaseCustomTimer) { result in
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
    
    func fetch(completion: @escaping (Result<[CustomTimerComponent], DataBaseError>) -> Void) {
        var fetchedCustomTimerComponents: [CustomTimerComponent] = []
        var dataBaseError: DataBaseError?
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: .fetchPhotosQueueLabel,
                                          attributes: .concurrent)

        dispatchGroup.enter()
        dataStore.fetchData() { result in
            defer { dispatchGroup.leave() }
            switch result {
            case .failure(let error):
                dataBaseError = DataBaseError(firestore: error)
            case .success(let timer):
                fetchedCustomTimerComponents = timer.map { CustomTimerComponent(dataBaseCustomTimer: $0) }
                fetchedCustomTimerComponents.enumerated().forEach { timer in
                    timer.element.timeInfomations.enumerated().forEach { [weak self] timeInfomation in
                        dispatchGroup.enter()
                        dispatchQueue.async(group: dispatchGroup) {
                            self?.dataStore.fetchPhoto(timerId: timer.element.id, photoId: timeInfomation.element.id) { result in
                                defer { dispatchGroup.leave() }
                                switch result {
                                case .failure(let error):
                                    let error = DataBaseError(storage: error)
                                    if error != .objectNotFound { dataBaseError = error }
                                case .success(let url):
                                    if let photoData = try? Data(contentsOf: url) {
                                        // URL
                                        // file:///var/mobile/Containers/Data/Application/BD8AA597-DB71-4F68-B1B9-32AD4CB565B0/Library/Caches/E1A204E4-21E8-43BE-97A8-8C9D6F7D8AB2/99F72466-EEE2-49AF-B99D-E37332570B5A.jpg
                                        fetchedCustomTimerComponents[timer.offset].timeInfomations[timeInfomation.offset].photo = photoData
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let dataBaseError = dataBaseError {
                completion(.failure(dataBaseError))
            } else {
                completion(.success(fetchedCustomTimerComponents))
            }
        }
        
    }
    
    func delete(customTimer: [CustomTimerComponent], completion: @escaping (Result<Any?, DataBaseError>) -> Void) {
        var dataBaseError: DataBaseError?
        let dispatchGroup = DispatchGroup()
        
        customTimer.forEach { timer in
            dispatchGroup.enter()
            dataStore.deleteData(timerId: timer.id) { result in
                defer { dispatchGroup.leave() }
                switch result {
                case .failure(let error):
                    dataBaseError = DataBaseError(firestore: error)
                case .success:
                    break
                }
            }
        }
        
        customTimer.forEach { timer in
            timer.timeInfomations.forEach { timeInfomation in
                dispatchGroup.enter()
                dataStore.deletePhoto(timerId: timer.id, photoId: timeInfomation.id) { result in
                    defer { dispatchGroup.leave() }
                    switch result {
                    case .failure(let error):
                        dataBaseError = DataBaseError(storage: error)
                    case .success:
                        break
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let dataBaseError = dataBaseError {
                completion(.failure(dataBaseError))
            } else {
                completion(.success(nil))
            }
        }
    }
}

// MARK: - extension String
private extension String {
    static let fetchPhotosQueueLabel = "CustomTimerApp.FetchPhotosQueueLabel"
}

// MARK: - DataBaseCustomTimerから共通の型へ変換
private extension CustomTimerComponent {
    init(dataBaseCustomTimer: DataBaseCustomTimer) {
        let timeInfomations = dataBaseCustomTimer.timeInfomations
            .map { TimeInfomation(dataBaseTimeInfomation: $0) }
        let createDate = dataBaseCustomTimer.createdDate?.dateValue()
        self = CustomTimerComponent(name: dataBaseCustomTimer.name,
                                    timeInfomations: timeInfomations,
                                    id: dataBaseCustomTimer.id,
                                    createdDate: createDate)
    }
}

private extension TimeInfomation {
    init(dataBaseTimeInfomation: DataBaseTimeInfomation) {
        self = TimeInfomation(time: Time(dataBaseTime: dataBaseTimeInfomation.time),
                              photo: nil,
                              text: dataBaseTimeInfomation.text,
                              type: dataBaseTimeInfomation.isRest ? .rest : .action,
                              id: dataBaseTimeInfomation.id)
    }
}

private extension Time {
    init(dataBaseTime: DataBaseTime) {
        self = Time(hour: dataBaseTime.hour,
                    minute: dataBaseTime.minute,
                    second: dataBaseTime.second)
    }
}
// MARK: - 共通の型からDataBaseCustomTimerへ変換
private extension DataBaseCustomTimer {
    init(customTimer: CustomTimerComponent) {
        let timeInfomations = customTimer.timeInfomations
            .map { DataBaseTimeInfomation(timeInfomation: $0) }
        let createdDate = (customTimer.createdDate == nil) ? nil : Timestamp(date: customTimer.createdDate!)
        self = DataBaseCustomTimer(name: customTimer.name,
                                   timeInfomations: timeInfomations,
                                   id: customTimer.id,
                                   createdDate: createdDate)
    }
}

private extension DataBaseTimeInfomation {
    init(timeInfomation: TimeInfomation) {
        self = DataBaseTimeInfomation(
            time: DataBaseTime(time: timeInfomation.time),
            text: timeInfomation.text,
            isRest: timeInfomation.type == .rest ? true : false,
            id: timeInfomation.id
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

// MARK: - errorMessage
extension DataBaseError {
    var errorMessage: String {
        switch self {
        case .aborted: return "操作中止されました。"
        case .alreadyExists: return "すでに保存されています。"
        case .cancelled: return "捜査がキャンセルされました。"
        case .deadlineExceeded: return "時間内に保存が完了しませんでした。"
        case .notFound: return "ドキュメントが見つかりませんでした。"
        case .permissionDenied: return "権限がありません。"
        case .unauthenticated: return "有効な認証情報がありません。"
        case .unknown: return "予期しないエラーが発生しました。"
      
        case .objectNotFound: return "オブジェクトが存在しません。"
        case .bucketNotFound: return "設定されているバケットはありません。"
        case .projectNotFound: return "プロジェクトがありません。"
        case .quotaExceeded: return "バケットのクオータが超過しました。"
        case .unauthorized: return "実行権限がありません。"
        case .retryLimitExceeded: return "操作の最大制限時間を超えました。"
        case .nonMatchingChecksum: return "チェックサムが一致しません。"
        case .downloadSizeExceeded: return "ダウンロードファイルのサイズがメモリ容量を超えています。"
        case .invalidArgument: return "無効な引数が指定されました。"
        }
    }
}
