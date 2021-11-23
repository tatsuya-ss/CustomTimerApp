//
//  CustomTimerProtocol.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/23.
//

import UIKit

protocol CustomTimerProtocol {
    func writePhotoDataToCached(timeInfomations: [TimeInfomation])
    func makePhotoImage(timeInfomation: TimeInfomation) -> UIImage?
}

extension CustomTimerProtocol where Self: UIViewController {
    
    func writePhotoDataToCached(timeInfomations: [TimeInfomation]) {
        timeInfomations.forEach {
            let fileName = $0.id.makeJPGFileName()
            let cachesDirectoryPathURL = DirectoryManagement().makeCacheDirectoryPathURL(fileName: fileName)
            do {
                try $0.photo?.write(to: cachesDirectoryPathURL)
            } catch {
                print(error)
            }
        }
    }
    
    func makePhotoImage(timeInfomation: TimeInfomation) -> UIImage? {
        guard let imageData = timeInfomation.photo,
              let image = UIImage(data: imageData) else {
                  switch timeInfomation.type {
                  case .action: return UIImage(systemName: "timer")
                  case .rest: return UIImage(named: "yasumi")
                  }
              }
        return image
    }
}
