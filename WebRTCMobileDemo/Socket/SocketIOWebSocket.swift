//
//  SocketIOWebSocket.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/23/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import SocketIO
import WebRTC

class SocketIOWebSocket: WebSocketProvider {
    
    weak var delegate: WebSocketProviderDelegate?
    var socket: SocketIOClient
    var manager: SocketManager
    var room: String
    
    init(url: URL, authToken: String, username: String, room: String, force: Bool) {
        let params: [String: Any] = [
            "auth_token": authToken,
            "username": username,
            "room": room,
            "force": true
        ]
        let config: SocketIOClientConfiguration = [.log(false), .path(Config.default.socketIOPath), .connectParams(params)]
        self.manager = SocketManager(socketURL: url, config: config)
        self.socket = manager.defaultSocket
        self.room = room
        self.registerEvents()
    }
    
    deinit {
        print("deinit SocketIOWebSocket")
    }
    
    func registerEvents() {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let self = self else { return }
            print(">>> socket connected")
            self.delegate?.webSocketDidConnect(self)
        }
        
        socket.on("unauthorized") { [weak self] data, ack in
            guard let self = self else { return }
            print(">>> socket unauthorized")
            self.socket.disconnect()
            self.delegate?.webSocketDidDisconnect(self)
        }
        
        socket.on("joined") { [weak self] data, ack in
            guard let self = self else { return }
//            print(">>> socket joined")
            self.delegate?.webSocketDidJoin(self)
        }
        
        socket.on("offer") { [weak self] data, ack in
//            print(">>> socket offer")
            self?.handleRemoteDescription(data: data)
        }
        
        socket.on("answer") { [weak self] data, ack in
//            print(">>> socket answer")
            self?.handleRemoteDescription(data: data)
        }
        
        socket.on("mute-video") { data, ack in
            print("socket mute-video", data)
        }
        
        socket.on("mute-audio") { data, ack in
            print("socket mute-audio", data)
        }
        
        socket.on("candidate") { [weak self] data, ack in
//            print(">>> socket candidate")
            self?.handleCandidate(data: data)
        }
        
        socket.on("customerror") { data, ack in
            print("socket customerror", data)
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("socket disconnected")
            guard let self = self else { return }
            self.delegate?.webSocketDidDisconnect(self)
        }
        
        socket.on(clientEvent: .error) { data, ack in
            print("socket error", data)
        }
    }
    
    func connect() {
        self.socket.connect(timeoutAfter: 10) {
            print("Socket Handler");
        }
    }
    
    func disconnect() {
        self.socket.disconnect()
    }
    
    func send(sessionDescription: SessionDescription, type: SdpType) {
        print(">>> sending ", type.socketEvent)
        let payload: [String: Any] = [
            "type": type.socketEvent,
            "sdp": ["type": type.socketEvent, "sdp": sessionDescription.sdp],
            "room": self.room
        ]
        self.socket.emit(type.socketEvent, payload)
    }
    
    func send(candidate: IceCandidate) {
        print(">>> sending candidate")
        let payload: [String: Any] = [
            "type": "candidate",
            "sdpMLineIndex": candidate.sdpMLineIndex,
            "sdpMid": candidate.sdpMid!,
            "candidate": candidate.sdp,
            "room": self.room
        ]
        self.socket.emit("candidate", payload)
    }
    
    private func handleRemoteDescription(data: [Any]) {
        guard let dictionary = data.first as? Dictionary<String, Any> else { return }
        
        do {
            let sessionDescription = try SessionDescription(from: dictionary)
            switch sessionDescription.type {
            case .offer:
                self.delegate?.webSocket(self, didReceiveOffer: sessionDescription)
            case .answer:
                self.delegate?.webSocket(self, didReceiveAnswer: sessionDescription)
            default:
                break
            }
            
        } catch let error {
            print(error)
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleCandidate(data: [Any]) {
        guard let dictionary = data.first as? Dictionary<String, Any> else { return }
        
        do {
            let candidate = try IceCandidate(from: dictionary)
            self.delegate?.webSocket(self, didReceiveCandidate: candidate)
            
        } catch let error {
            print(error)
            assertionFailure(error.localizedDescription)
        }
    }
}
