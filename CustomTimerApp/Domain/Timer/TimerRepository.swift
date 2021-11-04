//
//  TimerRepository.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/04.
//

import Foundation

protocol TimerRepositoryProtocol {
    func save(customTimer: CustomTimerComponent, completion: @escaping StoreResultHandler<Any?>)
}

final class TimerRepository: TimerRepositoryProtocol {
    
    private let dataStore: TimerDataStoreProtocol
    
    init(dataStore: TimerDataStoreProtocol = TimerDataStore()) {
        self.dataStore = dataStore
    }
    
    func save(customTimer: CustomTimerComponent,
              completion: @escaping StoreResultHandler<Any?>) {
        dataStore.save(customTimer: customTimer,
                       completion: completion)
    }
    
}
