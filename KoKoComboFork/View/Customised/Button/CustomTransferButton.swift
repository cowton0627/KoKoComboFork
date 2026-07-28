//
//  CustomTransferButton.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/18.
//

import UIKit

@IBDesignable
class CustomTransferButton: UIButton {

    @IBInspectable var borderColor: UIColor = UIColor.mainPeach {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.setTitleColor(UIColor.mainPeach, for: .normal)
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
}
