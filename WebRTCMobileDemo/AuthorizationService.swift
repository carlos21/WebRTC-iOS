//
//  AuthorizationService.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

struct AuthorizationService {
    
    private static let base = URL(string: "https://carlosduclos.dev")!
    private static let remote = Remote()
    
    static func authorize(username: String, completion: @escaping ((Result<AuthorizationResponse, Error>) -> Void)) {
        let params = ["username": username]
        
        var request = URLComponents(url: base.appendingPathComponent("/api/authorize"), resolvingAgainstBaseURL: true)!.postRequest!
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        
        print(">>> -1")
        Remote.run(request, completion: completion)
    }
}
