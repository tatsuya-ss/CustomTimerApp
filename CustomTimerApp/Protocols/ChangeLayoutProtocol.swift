//
//  ChangeLayoutProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/24.
//

import UIKit

protocol ChangeLayoutProtocol {
    func changeLayoutWhenKeyboardShow(notification: Notification, positionMaxY: CGFloat, withDuration: TimeInterval)
    func undoOriginalViewFrame(notification: Notification, withDuration: TimeInterval)
}

extension ChangeLayoutProtocol where Self: UIViewController {
    
    func changeLayoutWhenKeyboardShow(notification: Notification,
                                      positionMaxY: CGFloat,
                                      withDuration: TimeInterval = 0.25) {
        guard let keyboardPositionY = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.minY,
              self.view.frame == CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)  else { return }
        let duration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? withDuration
        let differenceY = keyboardPositionY - positionMaxY
        if keyboardPositionY < positionMaxY {
            UIView.animate(withDuration: duration) {
                self.view.frame = CGRect(x: 0,
                                         y: differenceY,
                                         width: self.view.bounds.width,
                                         height: self.view.bounds.height)
            }
        } else {
            undoOriginalViewFrame(notification: notification)
        }
    }
    
    func undoOriginalViewFrame(notification: Notification, withDuration: TimeInterval = 0.25) {
        let duration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? withDuration
        UIView.animate(withDuration: duration,
                       animations: {
            self.view.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.view.bounds.width,
                                     height: self.view.bounds.height)
        }, completion: nil)
    }
}
