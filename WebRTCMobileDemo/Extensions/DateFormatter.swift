//
//  DateFormatter.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var `default`: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
