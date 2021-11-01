//
//  Indicator.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import Foundation

enum FlashType {
    case success
    case progress
    case error
}

protocol IndicatorProtocol {
    func flash(flashType: FlashType, completion: @escaping () -> Void)
    func show(flashType: FlashType)
    func hide()
}

struct Indicator: IndicatorProtocol {
    
    private let indicator: PKHUDIndicatorProtocol
    
    init(indicator: PKHUDIndicatorProtocol = HUDIndicator()) {
        self.indicator = indicator
    }
    
    func flash(flashType: FlashType,
               completion: @escaping () -> Void) {
        indicator.flash(flashType: flashType, completion: completion)
    }
    
    func show(flashType: FlashType) {
        indicator.show(flashType: flashType)
    }
    
    func hide() {
        indicator.hide()
    }
    
}
