//
//  Message.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

struct Message {
    
    let message: String
    
    init(from dictionary: Dictionary<String, Any>) throws {
        guard let message = dictionary["message"] as? String else {
            throw ChatError.message
        }
        self.message = message
    }
}
