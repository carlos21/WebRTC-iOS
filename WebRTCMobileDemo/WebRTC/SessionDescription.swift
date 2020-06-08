//
//  SessionDescription.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC

struct SessionDescription: Codable {
    
    let sdp: String
    let type: SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        
        switch rtcSessionDescription.type {
        case .offer: self.type = .offer
        case .prAnswer: self.type = .prAnswer
        case .answer: self.type = .answer
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    init(from dictionary: Dictionary<String, Any>) throws {
        guard let sdp = dictionary["sdp"] as? String else {
            throw WebRTCError.sessionDescription("Session description is invalid")
        }
        
        guard let type = dictionary["type"] as? String, let sdpType = SdpType(rawValue: type) else {
            throw WebRTCError.sessionDescription("Type is invalid")
        }
        
        self.sdp = sdp
        self.type = sdpType
    }
    
    var rtcSessionDescription: RTCSessionDescription {
        return RTCSessionDescription(type: self.type.rtcSdpType, sdp: self.sdp)
    }
}
