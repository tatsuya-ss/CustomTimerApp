//
//  UserRepository.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation

protocol UserRepositoryProtocol {
    func signUp(email: String,
                password: String,
                completion: @escaping ResultHandler<Any?>)
    func logIn(email: String,
               password: String,
               completion: @escaping ResultHandler<Any?>)
    func signOut(completion: @escaping ResultHandler<Any?>)
    func logInStateListener(completion: @escaping ResultHandler<Any?>)
}

final class UserRepository: UserRepositoryProtocol {
    
    private let dataStore: UserDataStoreProtocol
    
    init(dataStore: UserDataStoreProtocol = UserDataStore()) {
        self.dataStore = dataStore
    }
    
    func signUp(email: String,
                password: String,
                completion: @escaping ResultHandler<Any?>) {
        dataStore.signUp(email: email,
                         password: password,
                         completion: completion)
    }
    
    func logIn(email: String,
               password: String,
               completion: @escaping ResultHandler<Any?>) {
        dataStore.logIn(email: email,
                        password: password,
                        completion: completion)
    }
    
    func signOut(completion: @escaping ResultHandler<Any?>) {
        dataStore.signOut(completion: completion)
    }
    
    func logInStateListener(completion: @escaping ResultHandler<Any?>) {
        dataStore.logInStateListener(completion: completion)
    }
    
}
