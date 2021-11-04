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
    
}
