//
//  UITapGestureRecognizer+Ext.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/18.
//

import UIKit

extension UITapGestureRecognizer {
    /// 檢查點擊特定文字範圍
    func didTapAttributedTextInLabel(label: UILabel,
                                     inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        let textContainer = NSTextContainer(size: label.bounds.size)
//        textContainer.lineFragmentPadding = 0
//        textContainer.maximumNumberOfLines = label.numberOfLines
//        textContainer.lineBreakMode = label.lineBreakMode
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let labelSize = label.bounds.size
        let textBoxSize = textBoundingBox.size
        let textOrigin = textBoundingBox.origin
        
        let textOffset = CGPoint(
            x: (labelSize.width - textBoxSize.width) * 0.5 - textOrigin.x,
            y: (labelSize.height - textBoxSize.height) * 0.5 - textOrigin.y
        )
        
        let location = CGPoint(x: locationOfTouchInLabel.x - textOffset.x,
                               y: locationOfTouchInLabel.y - textOffset.y)
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(characterIndex, targetRange)
    }
}

