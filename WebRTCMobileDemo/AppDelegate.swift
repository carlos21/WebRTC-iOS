//
//  AppDelegate.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    internal var window: UIWindow?
    private let config = Config.default

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = self.buildMainController()
        window.makeKeyAndVisible()
        self.window = window
        
        IQKeyboardManager.shared.enable = true
        
        return true
    }
}

extension AppDelegate {
    
    func buildMainController() -> UIViewController {
        let mainViewController = EnterRoomViewController()
        let navViewController = NavigationController(rootViewController: mainViewController)
        return navViewController
    }
}
