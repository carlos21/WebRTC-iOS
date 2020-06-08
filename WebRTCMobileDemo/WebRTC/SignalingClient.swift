//
//  SignalingClient.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC

protocol SignalClientDelegate: class {
 
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    
    // MARK: Properties
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let webSocket: WebSocketProvider
    private let webRTCClient: WebRTCClient
    private var timer: Timer?
    private var state = ThreadSafe(State.disconnected)
    
    weak var delegate: SignalClientDelegate?
    
    // MARK: Initialize
    
    init(webSocket: WebSocketProvider, webRTCClient: WebRTCClient) {
        self.webSocket = webSocket
        self.webRTCClient = webRTCClient
        self.webRTCClient.delegate = self
    }
    
    deinit {
        print("deinit SignalingClient")
    }
    
    // MARK: Methods
    
    func connect() {
        state.value = .connecting
        webSocket.delegate = self
        webSocket.connect()
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard self?.state.value == .disconnected else { return }
            print("Trying to reconnect :)")
            self?.webSocket.connect()
        }
    }
    
    func disconnect() {
        timer?.invalidate()
        self.webSocket.disconnect()
    }
    
    func send(sdp: SessionDescription, type: SdpType) {
        self.webSocket.send(sessionDescription: sdp, type: type)
    }
    
    func send(candidate: IceCandidate) {
        self.webSocket.send(candidate: candidate)
    }
}

extension SignalingClient: WebSocketProviderDelegate {
    
    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
        print(">>> webSocketDidConnect")
        state.value = .connected
        self.delegate?.signalClientDidConnect(self)
    }
    
    func webSocketDidJoin(_ webSocket: WebSocketProvider) {
        print(">>> webSocketDidJoin")
        self.webRTCClient.offer { [weak self] sdp in
            let sessionDescription = SessionDescription(from: sdp)
            self?.webSocket.send(sessionDescription: sessionDescription, type: .offer)
        }
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
        print(">>> webSocketDidDisconnect")
        state.value = .disconnected
        self.delegate?.signalClientDidDisconnect(self)
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveOffer remoteSdp: SessionDescription) {
        print(">>> webSocket:didReceiveOffer")
        self.webRTCClient.set(remoteSdp: remoteSdp.rtcSessionDescription) { [weak self] error in
            
            if let error = error {
                print(">>> Error setting remote sdp", error)
                return
            }
            
            self?.webRTCClient.answer { localSdp in
                let sessionDescription = SessionDescription(from: localSdp)
                self?.webSocket.send(sessionDescription: sessionDescription, type: .answer)
            }
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveAnswer remoteSdp: SessionDescription) {
        print(">>> webSocket:didReceiveAnswer")
        self.webRTCClient.set(remoteSdp: remoteSdp.rtcSessionDescription) { error in
            if let error = error {
                print(">>> webSocket:didReceiveAnswer:error", error)
            }
        }
    }
    
    func webSocket(_ webSocket: WebSocketProvider, didReceiveCandidate candidate: IceCandidate) {
        print(">>> webSocket:didReceiveCandidate")
        self.webRTCClient.set(remoteCandidate: candidate.rtcIceCandidate)
    }
}

extension SignalingClient: WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print(">>> client:didDiscoverLocalCandidate:candidate")
        let iceCandidate = IceCandidate(from: candidate)
        self.webSocket.send(candidate: iceCandidate)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        print(">>> client:didChangeConnectionState:state", state.description)
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        
    }
    
    func webRTCClient(_ client: WebRTCClient, negotiationNeeded peerConnection: RTCPeerConnection) {
        print(">>> client:negotiationNeeded")
        self.webRTCClient.offer { [weak self] sdp in
            let sessionDescription = SessionDescription(from: sdp)
            self?.webSocket.send(sessionDescription: sessionDescription, type: .offer)
        }
    }
}
