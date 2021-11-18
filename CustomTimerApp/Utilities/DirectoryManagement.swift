//
//  DirectoryManagement.swift
//  CustomTimerApp
//
//  Created by 坂本龍哉 on 2021/11/18.
//

import Foundation

struct DirectoryManagement {
    
    func makeCacheDirectoryPathURL(fileName: String) -> URL {
        let cachesDirectoryPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cachesDirectoryPathURL = cachesDirectoryPath.appendingPathComponent(fileName)
        
        return cachesDirectoryPathURL
    }
    
}
