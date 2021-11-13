//
//  TimerDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct DataBaseCustomTimer: Codable {
    var name: String
    var timeInfomations: [DataBaseTimeInfomation]
    let id: String
}

struct DataBaseTimeInfomation: Codable {
    var time: DataBaseTime
    var text: String?
    var isRest: Bool
    let id: String
}

struct DataBaseTime: Codable {
    var hour: Int
    var minute: Int
    var second: Int
}

typealias StoreResultHandler<T> = (Result<T, Error>) -> Void

protocol TimerDataStoreProtocol {
    func save(customTimer: DataBaseCustomTimer, completion: @escaping StoreResultHandler<Any?>)
    func savePhoto(customTimer: CustomTimerComponent, completion: @escaping StoreResultHandler<Any?>)
    func fetch(completion: @escaping StoreResultHandler<[DataBaseCustomTimer]>)
    func fetchPhotos(timerId: String, photoId: String, completion: @escaping StoreResultHandler<URL>)
}

final class TimerDataStore: TimerDataStoreProtocol {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    
    func save(customTimer: DataBaseCustomTimer,
              completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        do {
            try db.collection("user").document(user.uid).collection("timer").addDocument(from: customTimer)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    func savePhoto(customTimer: CustomTimerComponent,
                   completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        let storageRef = Storage.storage().reference()
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: .savePhotoQueueLabel,
                                          attributes: .concurrent)
        
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
    
    func fetch(completion: @escaping StoreResultHandler<[DataBaseCustomTimer]>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        
        let timerCollectionRef = db.collection("user").document(user.uid).collection("timer")
        timerCollectionRef.getDocuments() { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = querySnapshot?.documents else {
                completion(.failure(DataBaseError.unknown))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: .fetchTimerDataQueueLabel,
                                              attributes: .concurrent)
            
            var timers: [DataBaseCustomTimer] = []
            var dataBaseError: Error?
            dispatchQueue.async(group: dispatchGroup) {
                documents.forEach { document in
                    let result = Result { try document.data(as: DataBaseCustomTimer.self) }
                    switch result {
                    case .success(let timer):
                        if let timer = timer {
                            timers.append(timer)
                        } else { fatalError() }
                    case .failure(let error):
                        dataBaseError = error
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if let dataBaseError = dataBaseError {
                    completion(.failure(dataBaseError))
                } else {
                    completion(.success(timers))
                }
            }
            
        }
    }
    
    func fetchPhotos(timerId: String, photoId: String, completion: @escaping StoreResultHandler<URL>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        let photoRef =  Storage.storage().reference().child("users/\(user.uid)/timers/\(timerId)/\(photoId).jpg")
        let cachesDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                      .userDomainMask,
                                                                      true)[0]
        let photoName = "\(photoId).jpg"
        let cachesURL = URL(fileURLWithPath: "\(cachesDirectoryPath)/\(photoName)")
        let downloadTask = photoRef.write(toFile: cachesURL) { url, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(cachesURL))
            }
        }
        downloadTask.resume()
    }
    
}

private extension String {
    static let savePhotoQueueLabel = "CustomTimerApp.SavaPhotoQueue"
    static let fetchTimerDataQueueLabel = "CustomTimerApp.FetchTimerDataQueue"
}
