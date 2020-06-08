//
//  URLComponents+Extension.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

extension URLComponents {
    
    var request: URLRequest? {
        url.map { URLRequest(url: $0) }
    }
    
    var postRequest: URLRequest? {
        url.map {
            var request = URLRequest(url: $0)
            request.timeoutInterval = 10
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.httpMethod = "POST"
            return request
        }
    }
}
