//
//  CustomTabBar.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/5.
//

import UIKit

class CustomTabBar: UITabBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
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

