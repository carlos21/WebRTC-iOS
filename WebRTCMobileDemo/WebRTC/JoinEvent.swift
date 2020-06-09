//
//  JoinEvent.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/8/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

struct JoinEvent {
    
    let room: String
    let instruction: JoinInstruction
    
    init(from dictionary: Dictionary<String, Any>) throws {
        guard
            let room = dictionary["room"] as? String,
            let instruction = dictionary["instruction"] as? String,
            let joinInstruction = JoinInstruction(rawValue: instruction)
        else {
            throw SignalingError.join("Join error")
        }
        
        self.room = room
        self.instruction = joinInstruction
    }
}

enum JoinInstruction: String {
    
    case none = "none"
    case sendOffer = "send-offer"
}
