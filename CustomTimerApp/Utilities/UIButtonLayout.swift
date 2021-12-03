//
//  UIButtonLayout.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/23.
//

import UIKit

protocol UIButtonLayout {
    var cornerRadius: CGFloat { get }
    var borderWidth: CGFloat { get }
    var borderColor: CGColor { get }
}

struct SignUpButtonLayoutForSignInOrLogIn: UIButtonLayout {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0
    var borderColor: CGColor = UIColor.white.cgColor
}

struct LogInButtonLayoutForSignInOrLogIn: UIButtonLayout {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0
    var borderColor: CGColor = UIColor.black.cgColor
}

struct SignUpButtonLayout: UIButtonLayout {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0
    var borderColor: CGColor = UIColor.white.cgColor
}

struct LogInButtonLayout: UIButtonLayout {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0.5
    var borderColor: CGColor = UIColor.systemBlue.cgColor
}

struct SendButtonLayout: UIButtonLayout {
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 0.5
    var borderColor: CGColor = UIColor.black.cgColor
}
