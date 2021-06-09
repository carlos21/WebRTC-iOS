//
//  SocketIOObserver.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

protocol WebSocketProviderObserver: class {
    
    func provider(_ provider: WebSocketProviderObserver, didReceiveMessage message: ChatMessage)
}

extension WebSocketProviderObserver {
    
    func provider(_ provider: WebSocketProviderObserver, didReceiveMessage message: ChatMessage) { }
}

