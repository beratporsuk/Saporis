//
//  Net.swift
//  Saporis
//
//  Created by Berat PORSUK on 22.08.2025.
//


import Foundation

enum Net {
    static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.requestCachePolicy = .returnCacheDataElseLoad
        cfg.urlCache = URLCache(memoryCapacity: 20 * 1024 * 1024,
                                diskCapacity: 150 * 1024 * 1024,
                                diskPath: "saporis-urlcache")
        cfg.timeoutIntervalForRequest = 10
        cfg.waitsForConnectivity = true
        return URLSession(configuration: cfg)
    }()
}

