//
//  TimerUseCase.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/04.
//

import Foundation

protocol TimerUseCaseProtocol {
    func save(customTimer: CustomTimerComponent,
              completion: @escaping (Result<Any?, DataBaseError>) -> Void)
    func fetch(completion: @escaping (Result<[CustomTimerComponent], DataBaseError>) -> Void)
    func delete(customTimer: [CustomTimerComponent], completion: @escaping (Result<Any?, DataBaseError>) -> Void)
    func deleteUnnecessaryStorage(customTimer: [CustomTimerComponent],
                                  completion: @escaping StoreResultHandler<Any?>)
}

final class TimerUseCase: TimerUseCaseProtocol {
    
    private let repository: TimerRepositoryProtocol
    
    init(repository: TimerRepositoryProtocol = TimerRepository()) {
        self.repository = repository
    }
    
    func save(customTimer: CustomTimerComponent,
              completion: @escaping (Result<Any?, DataBaseError>) -> Void) {
        repository.save(customTimer: customTimer,
                        completion: completion)
    }
    
    func fetch(completion: @escaping (Result<[CustomTimerComponent], DataBaseError>) -> Void) {
        repository.fetch(completion: completion)
    }
    
    func delete(customTimer: [CustomTimerComponent], completion: @escaping (Result<Any?, DataBaseError>) -> Void) {
        repository.delete(customTimer: customTimer, completion: completion)
    }
    
    func deleteUnnecessaryStorage(customTimer: [CustomTimerComponent],
                                  completion: @escaping StoreResultHandler<Any?>) {
        repository.deleteUnnecessaryStorage(customTimer: customTimer, completion: completion)
    }
}
