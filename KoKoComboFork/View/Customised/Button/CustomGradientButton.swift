//
//  CustomGradientButton.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/14.
//

import UIKit

/// 客製化加好友 Button
class CustomGradientButton: UIButton {

    private let buttonTitle = "加好友"
    private let icAddFriendWhite = UIImage(named: "icAddFriendWhite")
    private let gradientLayer = CAGradientLayer()
    private let firstColor = #colorLiteral(red: 0.1019607843, green: 0.6, blue: 0.1019607843, alpha: 1).cgColor
    private let secondColor = #colorLiteral(red: 0.2980392157, green: 0.8, blue: 0.2980392157, alpha: 1).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // 設置漸層色
        gradientLayer.colors = [
            firstColor,
            secondColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20
        gradientLayer.masksToBounds = true
        
        // 加上漸層
        layer.insertSublayer(gradientLayer, at: 0)
        
        
        // 設置 UIButtonConfiguration
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .white
            
            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            config.attributedTitle = AttributedString(buttonTitle, 
                                                      attributes: container)
            
            config.image = icAddFriendWhite
            config.imagePlacement = .trailing
            
            let titleImgPadding: CGFloat = 60
            config.imagePadding = titleImgPadding
            let imageWidth = icAddFriendWhite?.size.width ?? 0
            let titlePadding = (titleImgPadding + imageWidth)

            // 設置內邊距
            config.contentInsets =
            NSDirectionalEdgeInsets(top: 10, 
                                    leading: 8 + titlePadding,
                                    bottom: 10,
                                    trailing: 8)
            
            self.configuration = config
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

