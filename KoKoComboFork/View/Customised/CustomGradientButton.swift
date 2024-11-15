//
//  CustomGradientButton.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/14.
//

import UIKit

class CustomGradientButton: UIButton {

    private let buttonTitle = "加好友"
    private let icAddFriendWhite = UIImage(named: "icAddFriendWhite")
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // 設置漸層顏色
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1).cgColor,
            UIColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20
        gradientLayer.masksToBounds = true
        
        // 添加漸層到按鈕
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

            // 設置內容的內邊距
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

