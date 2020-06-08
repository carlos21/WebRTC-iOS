//
//  TextField.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/6/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

class TextField: SkyFloatingLabelTextField {
    
    var didBecomeFirstResponder: (() -> Void)?
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - Override
    
    override func becomeFirstResponder() -> Bool {
        didBecomeFirstResponder?()
        return super.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @objc func onReturnPressed() {
        resignFirstResponder()
    }
    
    // MARK: - Methods
    
    private func setup() {
        titleFont = UIFont.systemFont(ofSize: 10)
        placeholderFont = UIFont.systemFont(ofSize: 15)
        font = UIFont.systemFont(ofSize: 15)
        textContentType = UITextContentType(rawValue: "")
        
        titleColor = .gray
        selectedTitleColor = .darkGray
        textColor = .darkGray
        lineColor = .lightGray
        lineHeight = 1.0
        selectedLineHeight = 1.0
        selectedLineColor = .darkGray
        disabledColor = .lightGray
        placeholderColor = .lightGray
        tintColor = .darkGray
        
        addTarget(self, action: #selector(onReturnPressed), for: .editingDidEndOnExit)
    }
}
