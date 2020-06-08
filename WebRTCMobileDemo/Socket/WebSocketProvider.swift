//
//  WebSocketProvider.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

protocol WebSocketProvider: class {
    
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func disconnect()
    func send(sessionDescription: SessionDescription, type: SdpType)
    func send(candidate: IceCandidate)
}

protocol WebSocketProviderDelegate: class {
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidJoin(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveOffer remoteSdp: SessionDescription)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveAnswer remoteSdp: SessionDescription)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveCandidate candidate: IceCandidate)
}
