//
//  VideoViewController.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/23/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC
import UIKit
import SnapKit

class VideoViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var backButton: RoundButton!
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    
    // MARK: Properties
    
    private let room: String
    private let username: String
    private let authToken: String
    private let webRTCClient: WebRTCClient
    private let signalingClient: SignalingClient
    
    // MARK: Initialize
    
    init(authToken: String, username: String, room: String) {
        self.webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        self.authToken = authToken
        self.username = username
        self.room = room
        
        let webSocketProvider = SocketIOWebSocket(url: Config.default.signalingServerUrl,
                                                  authToken: authToken,
                                                  username: username,
                                                  room: room,
                                                  force: true)
        self.signalingClient = SignalingClient(webSocket: webSocketProvider, webRTCClient: webRTCClient)
        
        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit VideoViewController")
        self.signalingClient.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if arch(arm64)
            // Using metal (arm64 only)
            let localRenderer = RTCMTLVideoView(frame: self.localVideoView.frame)
            let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
            localRenderer.videoContentMode = .scaleAspectFill
            remoteRenderer.videoContentMode = .scaleAspectFill
        #else
            // Using OpenGLES for the rest
            let localRenderer = RTCEAGLVideoView(frame: self.localVideoView.frame)
            let remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
        #endif
        
        if #available(iOS 13, *) {
            overrideUserInterfaceStyle = .light
        }
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        self.embedView(remoteRenderer, into: self.videoContainerView)
        self.signalingClient.connect()
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.snp.makeConstraints { $0.edges.equalTo(0) }
        containerView.layoutIfNeeded()
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
