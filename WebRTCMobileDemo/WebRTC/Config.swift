//
//  Config.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/23/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

// Set this to the machine's address which runs the signaling server

fileprivate let defaultSignalingServerUrl = URL(string: "https://carlosduclos.dev")!
fileprivate let defaultSocketIOPath = "/api/socket.io"

//fileprivate let defaultSignalingServerUrl = URL(string: "http://192.168.1.2:9000")!
//fileprivate let defaultSocketIOPath = "/socket.io"


// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    let socketIOPath: String
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl,
                                  webRTCIceServers: defaultIceServers,
                                  socketIOPath: defaultSocketIOPath)
}
