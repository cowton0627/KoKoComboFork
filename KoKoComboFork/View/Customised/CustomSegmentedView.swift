//
//  CustomSegmentedView.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/19.
//

//import UIKit
//
//class CustomSegmentedView: UIView {
//
//    var items: [String] = [] {
//        didSet {
//            setupButtons()
//        }
//    }
//    
//    var selectedIndex: Int = 0 {
//        didSet {
//            updateSelection()
//        }
//    }
//    
//    var selectionChanged: ((Int) -> Void)?
//
//    private var buttons: [UIButton] = []
//    private var underlineView: UIView!
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//
//    private func setupView() {
//        backgroundColor = .clear
//        
//        underlineView = UIView()
//        underlineView.backgroundColor = .systemPink
//        underlineView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(underlineView)
//    }
//
//    private func setupButtons() {
//        buttons.forEach { $0.removeFromSuperview() }
//        buttons.removeAll()
//
//        for (index, title) in items.enumerated() {
//            let button = UIButton(type: .system)
//            button.setTitle(title, for: .normal)
//            button.setTitleColor(.systemGray, for: .normal)
//            button.setTitleColor(.black, for: .selected)
//            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
//            button.tag = index
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            addSubview(button)
//            buttons.append(button)
//        }
//
//        updateSelection()
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layoutButtons()
//        updateUnderlinePosition()
//    }
//
//    private func layoutButtons() {
//        guard !buttons.isEmpty else { return }
//
//        let buttonWidth = frame.width / CGFloat(buttons.count)
//        for (index, button) in buttons.enumerated() {
//            button.frame = CGRect(x: CGFloat(index) * buttonWidth,
//                                  y: 0,
//                                  width: buttonWidth,
//                                  height: frame.height - 4)
//        }
//    }
//
//    private func updateUnderlinePosition() {
//        guard selectedIndex < buttons.count else { return }
//        let selectedButton = buttons[selectedIndex]
//        UIView.animate(withDuration: 0.3) {
//            self.underlineView.frame = CGRect(x: selectedButton.frame.origin.x,
//                                              y: self.frame.height - 4,
//                                              width: selectedButton.frame.width,
//                                              height: 4)
//        }
//    }
//
//    private func updateSelection() {
//        for (index, button) in buttons.enumerated() {
//            button.isSelected = (index == selectedIndex)
//            button.titleLabel?.font = button.isSelected
//                ? .systemFont(ofSize: 16, weight: .bold)
//                : .systemFont(ofSize: 16, weight: .regular)
//        }
//        updateUnderlinePosition()
//    }
//
//    @objc private func buttonTapped(_ sender: UIButton) {
//        selectedIndex = sender.tag
//        selectionChanged?(selectedIndex)
//    }
//}
