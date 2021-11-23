//
//  UIButtonLayout.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/23.
//

import UIKit

protocol UIButtonLayoutProtocol {
    var cornerRadius: CGFloat { get }
    var borderWidth: CGFloat { get }
    var borderColor: CGColor { get }
}

struct SignUpButtonLayout: UIButtonLayoutProtocol {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0.5
    var borderColor: CGColor = UIColor.white.cgColor
}

struct LogInButtonLayout: UIButtonLayoutProtocol {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0.5
    var borderColor: CGColor = UIColor.black.cgColor
}
