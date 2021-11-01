//
//  HUDIndicator.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/01.
//

import PKHUD

protocol PKHUDIndicatorProtocol {
    func flash(flashType: FlashType, completion: @escaping () -> Void)
    func show(flashType: FlashType)
    func hide()
}

struct HUDIndicator: PKHUDIndicatorProtocol {
    
    func flash(flashType: FlashType,
               completion: @escaping () -> Void) {
        let flashType = convertToHUDContentType(from: flashType)
        HUD.flash(flashType, onView: nil, delay: 0) { _ in
            completion()
        }
    }
    
    func show(flashType: FlashType) {
        let flashType = convertToHUDContentType(from: flashType)
        HUD.show(flashType, onView: nil)
    }
    
    func hide() {
        HUD.hide()
    }
    
    private func convertToHUDContentType(from type: FlashType) -> HUDContentType {
        switch type {
        case .success: return .success
        case .progress: return .progress
        case .error: return .error
        }
    }
    
}
