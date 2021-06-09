//
//  EnterRoomController.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/19/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit
import WebRTC
import SVProgressHUD

class EnterRoomViewController: UIViewController, AlertableController, LoadableController {
    
    // IBOutlets
    
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    // Properties
    
    
    // Intialize
    
    init() {
        super.init(nibName: String(describing: EnterRoomViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Login"
        usernameTextField.text = "sfaries"
        usernameTextField.autocorrectionType = .no
        roomTextField.text = "123"
        roomTextField.autocorrectionType = .no
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    // Actions
    
    @IBAction func joinPressed(_ sender: Any) {
        let username = usernameTextField.text ?? ""
        let room = roomTextField.text ?? ""
        
        showLoading()
        AuthorizationService.authorize(username: username) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()

            switch result {
            case .success(let response):
                let videoController = VideoViewController(authToken: response.token, username: username, room: room)
                self.navigationController?.pushViewController(videoController, animated: true)

            case .failure(let error):
                self.show(message: error.localizedDescription)
            }
        }
    }
    
    // Methods
  
    
}

//extension EnterRoomViewController: WebRTCClientDelegate {
//    
//    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("discovered local candidate")
//        self.localCandidateCount += 1
//        self.signalClient.send(candidate: candidate)
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//        <#code#>
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
//        <#code#>
//    }
//
//
//    
//}
