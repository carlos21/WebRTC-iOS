//
//  WebRTCClient.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/22/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import WebRTC
import AVFoundation

protocol WebRTCClientDelegate: class {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
    func webRTCClient(_ client: WebRTCClient, negotiationNeeded peerConnection: RTCPeerConnection)
}

final class WebRTCClient: NSObject {
    
    // MARK: Properties
    
    let streamId = "stream"
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory,
                                        decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    private var cameraPosition: AVCaptureDevice.Position = .unspecified
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "com.landgorilla.webrtcdemo.audio")
    private let videoQueue = DispatchQueue(label: "com.landgorilla.webrtcdemo.video")
    private let mediaConstraints = [
        kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
        kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
    ]
    
    private var camera: Camera = .front
    private var videoCapturer: RTCVideoCapturer?
    private var rtpVideoSender: RTCRtpSender?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    // MARK: Initialize
    
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(iceServers: [String]) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
        optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        
        let iceServer = RTCIceServer(urlStrings: iceServers, username: "guest", credential: "somepassword")
        let config = RTCConfiguration()
        config.iceTransportPolicy = .all
        config.iceServers = [iceServer]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        
        self.peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        
        super.init()
        
        self.peerConnection.delegate = self
        self.createMediaSenders()
        self.configureAudioSession()
    }
    
    deinit {
        print("deinit WebRTCClient")
    }
    
    // MARK: Signaling
    
    func createOffer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constraints = RTCMediaConstraints(mandatoryConstraints: self.mediaConstraints,
                                              optionalConstraints: nil)
        self.peerConnection.offer(for: constraints) { [weak self] sdp, error in
            self?.handleSessionDescription(sdp: sdp, error: error, completion: completion)
        }
    }
    
    func createAnswer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstraints, optionalConstraints: nil)
        self.peerConnection.answer(for: constrains) { [weak self] sdp, error in
            self?.handleSessionDescription(sdp: sdp, error: error, completion: completion)
        }
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        self.peerConnection.add(remoteCandidate)
    }
    
    func send(data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
    
    // MARK: Media
    
    func captureCamera(cameraPosition: AVCaptureDevice.Position, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else { return }
        guard self.cameraPosition != cameraPosition else { return }
        
        capturer.stopCapture {
            
            guard let camera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == cameraPosition }) else { return }
            
            // choose highest res
            let formats = RTCCameraVideoCapturer.supportedFormats(for: camera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }
            guard
                let format = formats.filter({
                    let height = CMVideoFormatDescriptionGetDimensions($0.formatDescription).height
                    let width = CMVideoFormatDescriptionGetDimensions($0.formatDescription).width
                    let size = max(height, width)
                    return (100 ... 1080).contains(size)
                }).last
            else {
                return
            }
            
            // choose highest fps
            let fps = format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last
            
            capturer.startCapture(with: camera, format: format, fps: Int(fps!.maxFrameRate)) { error in
//                print("Q MIERDA?", error)
                self.cameraPosition = cameraPosition
                completion?(.success(()))
            }
        }
    }
    
    func startCaptureLocalVideo(renderer: RTCVideoRenderer, cameraPosition: AVCaptureDevice.Position = .front) {
        self.captureCamera(cameraPosition: cameraPosition)
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    func toggleCamera(completion: ((Result<Void, Error>) -> Void)? = nil) {
        let position: AVCaptureDevice.Position
        switch self.cameraPosition {
        case .back:
            position = .front
            
        default:
            position = .back
        }
        
        captureCamera(cameraPosition: position, completion: completion)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    func createMediaSenders() {
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        addVideoTrack(videoTrack)
        
        self.remoteVideoTrack = self.peerConnection.transceivers.first(where: {
            $0.mediaType == .video
        })?.receiver.track as? RTCVideoTrack;
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func addVideoTrack(_ videoTrack: RTCVideoTrack) {
        self.localVideoTrack = videoTrack
        self.rtpVideoSender = self.peerConnection.add(videoTrack, streamIds: [streamId])
    }
    
    private func removeCurrentVideoTrack() {
        guard let rtpVideoSender =  self.rtpVideoSender else { return }
        self.peerConnection.removeTrack(rtpVideoSender)
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstraints)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if TARGET_OS_SIMULATOR
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    private func handleSessionDescription(sdp: RTCSessionDescription?,
                                          error: Error?,
                                          completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        if let error = error {
            print(">>> Error creating offer", error)
            return
        }
        
        guard let sdp = sdp else {
            print(">>> Session description is nil - offer")
            return
        }
        
        peerConnection.setLocalDescription(sdp, completionHandler: { error in
            
            if let error = error {
                print(">>> Set local description failed", error)
                return
            }
            
            completion(sdp)
        })
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        self.delegate?.webRTCClient(self, negotiationNeeded: peerConnection)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}

extension WebRTCClient {
    
    func enableAudio(flag: Bool) {
        self.setAudioEnabled(flag)
    }
    
    func enableVideo(flag: Bool) {
        self.localVideoTrack?.isEnabled = flag
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        let audioTracks = self.peerConnection.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
        audioTracks.forEach { $0.isEnabled = isEnabled }
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}

extension WebRTCClient {
    
    enum Camera {
        
        case front
        case back
    }
}
