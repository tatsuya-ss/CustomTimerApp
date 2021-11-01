//
//  UserDataStore.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation
import Firebase

enum AuthError: Error {
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case missingEmail
    case other
    
    init(error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .invalidEmail: self = .invalidEmail
            case .weakPassword: self = .weakPassword
            case .wrongPassword: self = .wrongPassword
            case .userNotFound: self = .userNotFound
            case .emailAlreadyInUse: self = .emailAlreadyInUse
            case .missingEmail: self = .missingEmail
            default: self = .other
            }
        } else {
            self = .other
        }
    }
    
    var errorMessage: String {
        switch self {
        case .invalidEmail: return "メールアドレスの形式に誤りが含まれます。"
        case .weakPassword: return "パスワードは６文字以上で入力してください。"
        case .wrongPassword: return "パスワードに誤りがあります。"
        case .userNotFound: return "こちらのメールアドレスは登録されていません。"
        case .emailAlreadyInUse: return "こちらのメールアドレスは既に登録されています。"
        case .missingEmail: return "メールアドレスの入力がありません。"
        case .other: return "失敗しました。"
        }
    }
    
}

typealias ResultHandler<T> = (Result<T, AuthError>) -> Void

protocol UserDataStoreProtocol {
    func signUp(email: String, password: String, completion: @escaping ResultHandler<Any?>)
    func logIn(email: String, password: String, completion: @escaping ResultHandler<Any?>)
    func signOut(completion: @escaping ResultHandler<Any?>)
    func logInStateListener(completion: @escaping ResultHandler<Any?>)
    func sendPasswordReset(email: String, completion: @escaping ResultHandler<Any?>)
}

final class UserDataStore: UserDataStoreProtocol {
    
    func signUp(email: String,
                password: String,
                completion: @escaping ResultHandler<Any?>) {
        Auth.auth().createUser(withEmail: email,
                               password: password) { result, error in
            if let error = error {
                let authError = AuthError(error: error)
                completion(.failure(authError))
                return
            }
            completion(.success(nil))
        }
    }
    
    func logIn(email: String,
               password: String,
               completion: @escaping ResultHandler<Any?>) {
        Auth.auth().signIn(withEmail: email,
                           password: password) { result, error in
            if let error = error {
                let authError = AuthError(error: error)
                completion(.failure(authError))
                return
            }
            completion(.success(nil))
        }
    }
    
    func signOut(completion: @escaping ResultHandler<Any?>) {
        do {
            try Auth.auth().signOut()
            completion(.success(nil))
        } catch {
            let authError = AuthError(error: error)
            completion(.failure(authError))
        }
    }
    
    func logInStateListener(completion: @escaping ResultHandler<Any?>) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                completion(.success(nil))
                return
            }
            completion(.failure(AuthError.userNotFound))
        }
    }
    
    func sendPasswordReset(email: String,
                           completion: @escaping ResultHandler<Any?>) {
        Auth.auth().languageCode = "ja"
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                let authError = AuthError(error: error)
                completion(.failure(authError))
                return
            }
            completion(.success(nil))
        }
    }
    
}
