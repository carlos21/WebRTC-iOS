//
//  UIColo.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    static let gray11c = UIColor(hexString: "#3d3d3d")
    
    public convenience init(hexString: String) {
        var string: String = hexString.uppercased()
        if (string.hasPrefix("#")) {
            string = String(string.suffix(from: string.index(string.startIndex, offsetBy: 1)))
        }
        
        guard string.count == 6 else {
            self.init(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
