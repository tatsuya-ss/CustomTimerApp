//
//  TimerDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum DataBaseError: Error {
    case aborted
    case alreadyExists
    case cancelled
    case deadlineExceeded
    case notFound
    case permissionDenied
    case unauthenticated
    case unknown
}

struct DataBaseCustomTimer: Encodable {
    var name: String
    var timeInfomations: [DataBaseTimeInfomation]
}

struct DataBaseTimeInfomation: Encodable {
    var time: DataBaseTime
    var text: String?
    var isRest: Bool
}

struct DataBaseTime: Encodable {
    var hour: Int
    var minute: Int
    var second: Int
}

typealias StoreResultHandler<T> = (Result<T, DataBaseError>) -> Void

protocol TimerDataStoreProtocol {
    func save(customTimer: CustomTimerComponent, completion: @escaping StoreResultHandler<Any?>)
}

final class TimerDataStore: TimerDataStoreProtocol {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser

    func save(customTimer: CustomTimerComponent,
              completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else { return }
        let customTimer = DataBaseCustomTimer(customTimer: customTimer)
        do {
            try db.collection("user").document(user.uid).collection("timer").addDocument(from: customTimer)
            completion(.success(nil))
        } catch {
            completion(.failure(DataBaseError(error: error)))
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
        }
    }

}
