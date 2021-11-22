//
//  SelectCellState.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/22.
//

import UIKit

protocol SelectCellState {
    var shadowOffset: CGSize { get }
    var shadowOpacity: Float { get }
    var shadowRadius: CGFloat { get }
}

struct SelectedCell: SelectCellState {
    var shadowOffset: CGSize = CGSize(width: -4.0, height: 4.0)
    var shadowOpacity: Float = 1.0
    var shadowRadius: CGFloat = 5
}

struct UnSelectedCell: SelectCellState {
    var shadowOffset: CGSize = CGSize(width: 0.0, height: 0)
    var shadowOpacity: Float = 0
    var shadowRadius: CGFloat = 0
}
