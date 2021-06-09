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
    
    @IBOutlet weak var microphoneButton: RoundButton!
    @IBOutlet weak var videoButton: RoundButton!
    @IBOutlet weak var hangUpButton: RoundButton!
    @IBOutlet weak var flipCameraButton: RoundButton!
    @IBOutlet weak var messagesButton: RoundButton!
    
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var meetingView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var webSocketStateLabel: UILabel!
    @IBOutlet weak var webRTCStateLabel: UILabel!
    
    // MARK: Properties
    
    private let room: String
    private let username: String
    private let authToken: String
    private let webRTCClient: WebRTCClient
    private let signalingClient: SignalingClient
    private let webSocketProvider: WebSocketProvider
    private var chatController: ChatViewController?
    
    private var joiningState: JoiningState = .joining {
        didSet { updateViewWithJoiningState() }
    }
    
    private var meetingState: MeetingState = .waitingForPartner {
        didSet { updateViewWithMeetingState() }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var messages: [ChatMessage] = []
    
    // MARK: Initialize
    
    init(authToken: String, username: String, room: String) {
        self.webSocketProvider = SocketIOWebSocket(url: Config.default.signalingServerUrl,
                                                   authToken: authToken,
                                                   username: username,
                                                   room: room,
                                                   force: true)
        self.webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        self.authToken = authToken
        self.username = username
        self.room = room
        self.signalingClient = SignalingClient(webSocket: webSocketProvider, webRTCClient: webRTCClient)
        
        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
        
        self.signalingClient.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit VideoViewController")
        self.signalingClient.disconnect()
        webSocketProvider.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
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
        
        updateViewWithJoiningState()
        updateViewWithMeetingState()
    }
    
    // MARK: Actions
    
    @IBAction func onHangUpPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onMicrophonePressed(_ sender: Any) {
        microphoneButton.isSelected = !microphoneButton.isSelected
        webRTCClient.enableAudio(flag: !microphoneButton.isSelected)
    }
    
    @IBAction func onVideoPressed(_ sender: Any) {
        videoButton.isSelected = !videoButton.isSelected
        webRTCClient.enableVideo(flag: !videoButton.isSelected)
    }
    
    @IBAction func flipCameraPressed(_ sender: Any) {
        webRTCClient.toggleCamera()
    }
    
    @IBAction func onMessagesPressed(_ sender: Any) {
        let chatController = ChatViewController(webSocketProvider: self.webSocketProvider, messages: messages)
        
        let navigationController = NavigationController(rootViewController: chatController, navigationBarHidden: false)
        navigationController.presentationController?.delegate = self
        present(navigationController, animated: true, completion: nil)
        
        self.chatController = chatController
    }
    
    // MARK: Methods
    
    private func setup() {
        microphoneButton.setImage(UIImage(named: "microphone-on"), for: .normal)
        microphoneButton.setImage(UIImage(named: "microphone-off"), for: .selected)
        videoButton.setImage(UIImage(named: "video-on"), for: .normal)
        videoButton.setImage(UIImage(named: "video-off"), for: .selected)
        webSocketProvider.addObserver(self)
    }
    
    private func updateViewWithMeetingState() {
        switch meetingState {
        case .active:
            webRTCStateLabel.isHidden = true
            videoContainerView.isHidden = false
            
        case .connectingToPartner, .waitingForPartner, .error:
            webRTCStateLabel.isHidden = false
            videoContainerView.isHidden = true
        }
        
        webRTCStateLabel.text = meetingState.description
    }
    
    private func updateViewWithJoiningState() {
        switch joiningState {
        case .joined:
            webSocketStateLabel.isHidden = true
            meetingView.isHidden = false
            
        case .joining:
            webSocketStateLabel.isHidden = false
            meetingView.isHidden = true
            
        case .disconnected:
            webSocketStateLabel.isHidden = false
            meetingView.isHidden = true
        }
        
        webSocketStateLabel.text = joiningState.description
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.snp.makeConstraints { $0.edges.equalTo(0) }
        containerView.layoutIfNeeded()
    }
}

extension VideoViewController: SignalClientDelegate {
    
    func signalClient(_ signalClient: SignalingClient, didChangeState state: MeetingState) {
        self.meetingState = state
    }
    
    func signalClient(_ signalClient: SignalingClient, didChangeJoiningState state: JoiningState) {
        self.joiningState = state
    }
}

extension VideoViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        chatController = nil
        print("presentationControllerDidDismiss")
        print("chatController", chatController)
    }
}

extension VideoViewController: WebSocketProviderObserver {
    
    func provider(_ provider: WebSocketProviderObserver, didReceiveMessage message: ChatMessage) {
        if let chatController = self.chatController {
            chatController.insertMessage(message)
        }
        messages.append(message)
    }
}

extension MeetingState {
    
    var description: String {
        switch self {
        case .waitingForPartner: return "Waiting for partner..."
        case .connectingToPartner: return "Partner is connecting..."
        case .active: return "Done!"
        case .error: return "An error has occurred. Please, try again."
        }
    }
}

extension JoiningState {
    
    var description: String {
        switch self {
        case .joined: return "Done!"
        case .joining: return "Joining..."
        case .disconnected(let error):
            switch error {
            case .join(let message): return message
            case .userCancel: return "User canceled"
            }
        }
    }
}
