//
//  UserUseCase.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation

protocol UserUseCaseProtocol {
    func signUp(email: String, password: String, completion: @escaping ResultHandler<Any?>)
    func logIn(email: String, password: String, completion: @escaping ResultHandler<Any?>)
    func signOut(completion: @escaping ResultHandler<Any?>)
    func logInStateListener(completion: @escaping ResultHandler<Any?>)
    func sendPasswordReset(email: String, completion: @escaping ResultHandler<Any?>)
}

final class UserUseCase: UserUseCaseProtocol {
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func signUp(email: String,
                password: String,
                completion: @escaping ResultHandler<Any?>) {
        repository.signUp(email: email,
                          password: password,
                          completion: completion)
    }
    
    func logIn(email: String,
               password: String,
               completion: @escaping ResultHandler<Any?>) {
        repository.logIn(email: email,
                         password: password,
                         completion: completion)
    }
    
    func signOut(completion: @escaping ResultHandler<Any?>) {
        repository.signOut(completion: completion)
    }
    
    func logInStateListener(completion: @escaping ResultHandler<Any?>) {
        repository.logInStateListener(completion: completion)
    }
    
    func sendPasswordReset(email: String,
                           completion: @escaping ResultHandler<Any?>) {
        repository.sendPasswordReset(email: email,
                                     completion: completion)
    }
    
}
