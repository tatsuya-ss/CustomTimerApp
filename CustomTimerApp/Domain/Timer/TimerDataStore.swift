//
//  TimerDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// https://stackoverflow.com/questions/64872729/firebase-firestore-using-servertimestamp-in-a-custom-object-in-swift
struct DataBaseCustomTimer: Codable {
    var name: String
    var timeInfomations: [DataBaseTimeInfomation]
    let id: String
    @ServerTimestamp var createdDate: Timestamp?
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
    func saveData(customTimer: DataBaseCustomTimer, completion: @escaping StoreResultHandler<Any?>)
    func savePhoto(customTimer: CustomTimerComponent, completion: @escaping StoreResultHandler<Any?>)
    func fetchData(completion: @escaping StoreResultHandler<[DataBaseCustomTimer]>)
    func fetchPhoto(timerId: String, photoId: String, completion: @escaping StoreResultHandler<URL>)
    func deleteData(timerId: String, completion: @escaping StoreResultHandler<Any?>)
    func deletePhoto(timerId: String, photoId: String, completion: @escaping StoreResultHandler<Any?>)
}

final class TimerDataStore: TimerDataStoreProtocol {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    let storageRef = Storage.storage().reference()

    func saveData(customTimer: DataBaseCustomTimer,
              completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        do {
            try db.collection("user").document(user.uid).collection("timer").document(customTimer.id).setData(from: customTimer)
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
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: .savePhotoQueueLabel,
                                          attributes: .concurrent)
        
        customTimer.timeInfomations.forEach {
            if let photoData =  $0.photo {
                let fileName = $0.id.makeJPGFileName()
                let photoRef =  storageRef.child("users/\(user.uid)/timers/\(customTimer.id)/\(fileName)")
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
    
    func fetchData(completion: @escaping StoreResultHandler<[DataBaseCustomTimer]>) {
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
    
    // TODO: たまにweakSelf.fetcherCompletion(data, error);の箇所でThread 1: EXC_BAD_ACCESS (code=1, address=0x10)の実行時エラーが出る。
    func fetchPhoto(timerId: String, photoId: String, completion: @escaping StoreResultHandler<URL>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        let fileName = photoId.makeJPGFileName()
        let photoRef =  Storage.storage().reference().child("users/\(user.uid)/timers/\(timerId)/\(fileName)")
        let cachesDirectoryPathURL = DirectoryManagement().makeCacheDirectoryPathURL(fileName: fileName)
        let downloadTask = photoRef.write(toFile: cachesDirectoryPathURL) { url, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(cachesDirectoryPathURL))
            }
        }
        downloadTask.resume()
    }
    
    func deleteData(timerId: String, completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        db.collection("user").document(user.uid).collection("timer").document(timerId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    func deletePhoto(timerId: String, photoId: String, completion: @escaping StoreResultHandler<Any?>) {
        guard let user = user else {
            completion(.failure(DataBaseError.unknown))
            return
        }
        let fileName = photoId.makeJPGFileName()
        let photoRef =  storageRef.child("users/\(user.uid)/timers/\(timerId)/\(fileName)")
        photoRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(nil))
            }
        }
    }
    
}

// MARK: - extension String
private extension String {
    static let savePhotoQueueLabel = "CustomTimerApp.SavaPhotoQueue"
    static let fetchTimerDataQueueLabel = "CustomTimerApp.FetchTimerDataQueue"
}
