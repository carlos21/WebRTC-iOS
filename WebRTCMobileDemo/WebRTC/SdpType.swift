//
//  SdpType.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC

enum SdpType: String, Codable {
    case offer, prAnswer, answer
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer: return .offer
        case .answer: return .answer
        case .prAnswer: return .prAnswer
        }
    }
    
    var socketEvent: String {
        switch self {
        case .offer: return "offer"
        case .answer: return "answer"
        case .prAnswer: return "prAnswer"
        }
    }
}
