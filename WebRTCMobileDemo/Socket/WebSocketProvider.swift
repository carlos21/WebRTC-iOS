//
//  WebSocketProvider.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

protocol WebSocketProvider: class {
    
    var observations: [ObjectIdentifier: Observation] { get set }
    var delegate: WebSocketProviderDelegate? { get set }
    func connect()
    func disconnect()
    func send(sessionDescription: SessionDescription, type: SdpType)
    func send(candidate: IceCandidate)
    func send(message: ChatMessage)
}

extension WebSocketProvider {
    
    func addObserver(_ observer: WebSocketProviderObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: WebSocketProviderObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
    
    func postEvent(_ event: Event) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            DispatchQueue.main.async {
                switch event {
                case .newMessage(let message):
                    observer.provider(observer, didReceiveMessage: message)
                }
            }
        }
    }
}

protocol WebSocketProviderDelegate: class {
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider)
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider)
    func webSocket(_ webSocket: WebSocketProvider, didJoinWithEvent event: JoinEvent)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveOffer remoteSdp: SessionDescription)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveAnswer remoteSdp: SessionDescription)
    func webSocket(_ webSocket: WebSocketProvider, didReceiveCandidate candidate: IceCandidate)
}

struct Observation {
    
    weak var observer: WebSocketProviderObserver?
}

enum Event {
    
    case newMessage(ChatMessage)
}
