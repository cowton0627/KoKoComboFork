//
//  FriendsDetailViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/14.
//

import UIKit

protocol FriendsDetailViewControllerDelegate: AnyObject {
    
}

class FriendsDetailViewController: UIViewController {
    
    weak var delegate: FriendsDetailViewControllerDelegate?
    
    // MARK: - Properties
    private let linkedLabelText = "幫助好友更快找到你？設定 KOKO ID"
    private let linkedText = "設定 KOKO ID"
    
    // MARK: - IBOutlet
    @IBOutlet weak var kokoFriendsImgView: UIImageView!
    @IBOutlet var labelCollection: [UILabel]!
    @IBOutlet weak var addFriendsButton: CustomGradientButton!
    @IBOutlet weak var linkedLabel: UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
     }
    
    // MARK: - Private Func
    private func hideOrShowView() {
        kokoFriendsImgView.isHidden = true
        for label in labelCollection {
            label.isHidden = true
        }
        addFriendsButton.isHidden = true
        linkedLabel.isHidden = true
    }
    
    
    private func setupLabel() {
        let attributedString = NSMutableAttributedString(string: linkedLabelText)
        let linkRange = (linkedLabelText as NSString).range(of: linkedText)
        
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.systemPink,
                                      range: linkRange)
        attributedString.addAttribute(.underlineStyle, 
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: linkRange)
        
        linkedLabel.attributedText = attributedString
        linkedLabel.isUserInteractionEnabled = true
        
        let tapGesture =
        UITapGestureRecognizer(target: self, action: #selector(handleLinkTapped(_:)))
        linkedLabel.addGestureRecognizer(tapGesture)
    }
        
    // MARK: - Objc Func
    @objc 
    private func handleLinkTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = linkedLabel.attributedText?.string else { return }
        let range = (text as NSString).range(of: linkedText)
        
        if gesture.didTapAttributedTextInLabel(label: linkedLabel, inRange: range) {
            print("Link Tapped")
        }
    }
    

}

extension UITapGestureRecognizer {
    /// 檢查用戶是否點擊了 UILabel 中的特定文字範圍
    func didTapAttributedTextInLabel(label: UILabel, 
                                     inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else { return false }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textOffset = CGPoint(x: (label.bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                 y: (label.bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let location = CGPoint(x: locationOfTouchInLabel.x - textOffset.x,
                               y: locationOfTouchInLabel.y - textOffset.y)
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(characterIndex, targetRange)
    }
}
