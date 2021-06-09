//
//  NavigationController.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 5/24/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    var allowBackGesture: Bool = true
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }
    
    convenience init(rootViewController: UIViewController, navigationBarHidden: Bool = true) {
        self.init(rootViewController: rootViewController)
        setup(navigationBarHidden: navigationBarHidden)
    }
    
    override open var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // workaround to ignore
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Methods
    
//    @available(iOS 13.0, *) override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .darkContent
//    }
    
    func setup(navigationBarHidden: Bool = true) {
        modalPresentationStyle = .pageSheet
        interactivePopGestureRecognizer?.delegate = self
        navigationBar.isHidden = navigationBarHidden
    }
    
    func setupUI() {
        let largeTitleColor: UIColor = .white
        let backgoundColor: UIColor = .gray11c
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.backgroundColor = backgoundColor

            navigationBar.standardAppearance = navBarAppearance
            navigationBar.compactAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationBar.prefersLargeTitles = false
            navigationBar.isTranslucent = false
            navigationBar.tintColor = backgoundColor

        } else {
            // Fallback on earlier versions
            navigationBar.barTintColor = backgoundColor
            navigationBar.tintColor = backgoundColor
            navigationBar.isTranslucent = false
        }
    }
    
    func setupBackButton() {
        let childs = navigationController?.children.count ?? 0
        
        guard childs > 1 else {
            navigationItem.leftBarButtonItem = nil;
            return
        }
        
        let backImage = UIImage(named: "left-arrow")
        let backButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    @objc func back() {
        popViewController(animated: true)
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return true
        }
        
        return viewControllers.count > 1 && allowBackGesture
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
