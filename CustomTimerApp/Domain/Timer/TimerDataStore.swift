//
//  TimerDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct DataBaseCustomTimer: Encodable {
    var name: String
    var timeInfomations: [DataBaseTimeInfomation]
    let id: String
}

struct DataBaseTimeInfomation: Encodable {
    var time: DataBaseTime
    var text: String?
    var isRest: Bool
    let id: String
}

struct DataBaseTime: Encodable {
    var hour: Int
    var minute: Int
    var second: Int
}

typealias StoreResultHandler<T> = (Result<T, Error>) -> Void

protocol TimerDataStoreProtocol {
    func save(customTimer: DataBaseCustomTimer, completion: @escaping StoreResultHandler<Any?>)
    func savePhoto(customTimer: CustomTimerComponent, completion: @escaping StoreResultHandler<Any?>)
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
    
    func savePhoto(customTimer: CustomTimerComponent,
                   completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else { return }
        let storageRef = Storage.storage().reference()
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "dataStoreSavePhoto", attributes: .concurrent)
        
        customTimer.timeInfomations.forEach {
            if let photoData =  $0.photo {
                let photoRef =  storageRef.child("users/\(user.uid)/timers/\(customTimer.id)/\($0.id).jpg")
                dispatchQueue.async(group: dispatchGroup) {
                    photoRef.putData(photoData, metadata: nil) { metadata, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(nil))
        }
        
    }
    
}
