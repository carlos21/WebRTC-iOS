//
//  Error.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/31/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

enum WebRTCError: Error {
    case sessionDescription(String)
    case candidate(String)
    case type(String)
}

enum SignalingError: Error {
    case join(String)
}
