//
//  UserDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation
import Firebase

typealias ResultHandler<T> = (Result<T, Error>) -> Void

protocol UserDataStoreProtocol {
    func signUp(email: String, password: String,
                completion: @escaping ResultHandler<Any?>)
    func logIn()
    func isLogIn() -> Bool
}

final class UserDataStore: UserDataStoreProtocol {
    
    func signUp(email: String,
                password: String,
                completion: @escaping ResultHandler<Any?>) {
        Auth.auth().createUser(withEmail: email,
                               password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(nil))
        }
    }
    
    func logIn() {
        
    }
    
    func isLogIn() -> Bool {
        false
    }
    
}
