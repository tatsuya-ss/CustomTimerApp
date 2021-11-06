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

struct DataBaseCustomTimer: Encodable {
    var name: String
    var timeInfomations: [DataBaseTimeInfomation]
    let id: String
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

typealias StoreResultHandler<T> = (Result<T, Error>) -> Void

protocol TimerDataStoreProtocol {
    func save(customTimer: DataBaseCustomTimer, completion: @escaping StoreResultHandler<Any?>)
}

final class TimerDataStore: TimerDataStoreProtocol {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func save(customTimer: DataBaseCustomTimer,
              completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else { return }
        do {
            try db.collection("user").document(user.uid).collection("timer").addDocument(from: customTimer)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
}
