//
//  Remote.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

struct Remote {
    
    static var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        config.waitsForConnectivity = true
        return config
    }
    
    static var session = URLSession(configuration: configuration)
    
    static func run<T: Decodable>(_ request: URLRequest,
                                  completion: @escaping (Result<T, Error>) -> Void) {
        print(">>> 0")
        let task = self.session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            print(">>> 1")
            DispatchQueue.main.async {
                
                print(">>> 2")
                if let error = error {
                    completion(.failure(error))
                    return
                }
                print(">>> 3")
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(response))
                } catch let error {
                    print(error)
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
