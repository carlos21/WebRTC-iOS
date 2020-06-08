//
//  ThreadSafe.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/6/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation

struct ThreadSafe<Value> {
    
    private let queue = DispatchQueue(label: "com.carlosduclos.webrtcdemo", attributes: .concurrent)
    private var _value: Value
  
    init(_ value: Value) {
        self._value = value
    }
  
    var value: Value {
        get {
            queue.sync { _value }
        }
        set {
            queue.sync(flags: .barrier) {
                self._value = newValue
            }
        }
    }
}
