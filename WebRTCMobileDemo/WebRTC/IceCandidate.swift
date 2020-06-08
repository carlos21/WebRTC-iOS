//
//  IceCandidate.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC

struct IceCandidate: Codable {
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    
    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdpMid = iceCandidate.sdpMid
        self.sdp = iceCandidate.sdp
    }
    
    init(from dictionary: Dictionary<String, Any>) throws {
        let sdpMid = dictionary["sdpMid"] as? String
        
        guard
            let sdp = dictionary["candidate"] as? String,
            let sdpMLineIndex = dictionary["sdpMLineIndex"] as? Int32
        else {
            throw WebRTCError.candidate("Candidate data is invalid")
        }
        
        self.sdp = sdp
        self.sdpMLineIndex = sdpMLineIndex
        self.sdpMid = sdpMid
    }
    
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.sdp, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}
