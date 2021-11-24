//
//  UIButtonLayoutProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/23.
//

import UIKit

protocol UIButtonLayoutProtocol {
    func setupButton(button: UIButton, layout: UIButtonLayout)
}

extension UIButtonLayoutProtocol where Self: UIViewController {
    
    func setupButton(button: UIButton, layout: UIButtonLayout) {
        button.layer.cornerRadius = layout.cornerRadius
        button.layer.borderWidth = layout.borderWidth
        button.layer.borderColor = layout.borderColor
    }
    
}
