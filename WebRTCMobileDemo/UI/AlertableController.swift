//
//  AlertableController.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/6/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit

protocol AlertableController: class {
    
    func show(title: String?, message: String, actionTitle: String?, cancelTitle: String?, completion: (() -> Void)?)
}

extension AlertableController where Self: UIViewController {
    
    func show(title: String? = "",
              message: String,
              actionTitle: String? = nil,
              cancelTitle: String? = "Accept",
              completion: (() -> Void)? = nil) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: cancelTitle, style: .default, handler: { _ in
            if actionTitle == nil {
                completion?()
            }
        })
        controller.addAction(cancel)
        
        if let actionTitle = actionTitle {
            let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                completion?()
            })
            controller.addAction(action)
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func showConfirm(title: String? = "",
                     message: String,
                     actionTitle: String? = "Yes",
                     cancelTitle: String? = "No",
                     completion: (() -> Void)? = nil) {
        
        show(title: title,
             message: message,
             actionTitle: actionTitle,
             cancelTitle: cancelTitle,
             completion: completion)
    }
    
    func showConfirmCancel(title: String? = "",
                           message: String,
                           actionTitle: String? = "Yes",
                           cancelTitle: String? = "No",
                           completion: (() -> Void)? = nil,
                           completionCancel: (() -> Void)? = nil) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: cancelTitle, style: .default, handler: { _ in
            completionCancel?()
        })
        controller.addAction(cancel)
        
        let action = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            completion?()
        })
        controller.addAction(action)
        
        self.present(controller, animated: true, completion: nil)
    }
}
