//
//  UserUseCase.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation

protocol UserUseCaseProtocol {
    func signUp(email: String, password: String,
                completion: @escaping ResultHandler<Any?>)
    func logIn()
    func logInStateListener(completion: @escaping ResultHandler<Any?>)
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
    
    func logIn() {
        
    }
    
    func logInStateListener(completion: @escaping ResultHandler<Any?>) {
        repository.logInStateListener(completion: completion)
    }
    
}
