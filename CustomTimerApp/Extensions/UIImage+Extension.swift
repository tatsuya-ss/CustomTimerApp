//
//  UIImage+Extension.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/09/19.
//

import UIKit

extension UIImage {
    func convertImageToData() -> Data? {
        guard let jpegData = self.jpegData(compressionQuality: 1.0) else { return nil }
        return jpegData
    }
}
