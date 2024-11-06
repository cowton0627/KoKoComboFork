//
//  CustomTabBar.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/5.
//

import UIKit

class CustomTabBar: UITabBar {
    
//    private let icTabbarHomeOff = "icTabbarHomeOff"
//    private let centerButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupCenterButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        setupCenterButton()
    }

//    private func setupCenterButton() {
//        centerButton.frame.size = CGSize(width: 70, height: 70)
//        centerButton.setImage(UIImage(named: "\(icTabbarHomeOff)"), for: .normal)
//        centerButton.backgroundColor = .white
//        centerButton.layer.cornerRadius = centerButton.frame.size.width / 2
//        centerButton.clipsToBounds = true
//        addSubview(centerButton)
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // 設置中心按鈕的位置
//        let tabBarHeight = self.bounds.height
//        centerButton.center = CGPoint(x: self.bounds.midX, y: tabBarHeight / 2 - 15)

        // 調整標籤按鈕的位置，使它們不與中心按鈕重疊
//        let tabBarButtonClass: AnyClass? = NSClassFromString("UITabBarButton")
//        for view in self.subviews {
//            if view.isKind(of: tabBarButtonClass!) {
//                view.frame.origin.y = 5 // 調整標籤按鈕的 Y 座標以減少與中心按鈕重疊
//            }
//        }
        
//        // 計算每個 TabBarButton 的寬度
//        let tabBarButtons = self.subviews.filter {
//            $0.isKind(of: NSClassFromString("UITabBarButton")!)
//        }
//        let numberOfButtons = tabBarButtons.count
//        
//        guard numberOfButtons > 0 else { return }
//        
//        let buttonWidth = self.bounds.width / CGFloat(numberOfButtons)
//        for (index, button) in tabBarButtons.enumerated() {
//            button.frame = CGRect(x: CGFloat(index) * buttonWidth,
//                                  y: button.frame.origin.y,
//                                  width: buttonWidth,
//                                  height: button.frame.height)
//        }
        
//        self.backgroundColor = .gray
    }
    
    private var shapeLayer: CALayer?
        
    override func draw(_ rect: CGRect) {
        self.addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.5

        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {

        let height: CGFloat = 9.0
        let width: CGFloat = 21.0
        let centerWidth = self.frame.width / 2
        let path = UIBezierPath()

        path.move(to: CGPoint(x: 0, y: 0)) // start top left
        path.addLine(to: CGPoint(x: (centerWidth - width), y: 0)) // draw curve
        
        // first curve down
        path.addCurve(
            to: CGPoint(x: centerWidth, y: -height),
            controlPoint1: CGPoint(x: centerWidth - width*2/3, y: -height*3/4),
            controlPoint2: CGPoint(x: centerWidth - width/3, y: -height*4/5)
        )
        // second curve up
        path.addCurve(
            to: CGPoint(x: centerWidth + width, y: 0),
            controlPoint1: CGPoint(x: centerWidth + width/3, y: -height*4/5),
            controlPoint2: CGPoint(x: (centerWidth + width*2/3), y: -height*3/4)
        )

        // complete the rect
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()

        return path.cgPath
    }
    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var newSize = super.sizeThatFits(size)
//        newSize.height = 80
//        return newSize
//    }
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let convertedPoint = centerButton.convert(point, from: self)
//        if centerButton.bounds.contains(convertedPoint) {
//            return centerButton
//        }
//        return super.hitTest(point, with: event)
//    }
}

