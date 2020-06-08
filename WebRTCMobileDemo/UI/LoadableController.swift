//
//  LoadableController.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/6/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

protocol LoadableController: class {
    
    func showLoading()
}

extension LoadableController where Self: UIViewController {

    func showLoading() {
        SVProgressHUD.show()
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
        view.isUserInteractionEnabled = true
    }
}
