//
//  CustomSegmentedView.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/19.
//

import UIKit

/// 兩段式頁籤: 好友 / 聊天.
/// 自管選中狀態與底線位置, 不使用 UISegmentedControl, 以免踩到 iOS 13+
/// 內建白色 track / segment 高度等不可控的視覺問題.
class CustomSegmentedView: UIView {

    private let titles = ["好友", "聊天"]
    private let underlineHeight: CGFloat = 4
    private let underlineWidthRatio: CGFloat = 0.5 // 底線寬 = 該段寬度的一半
    private let animationDuration: TimeInterval = 0.3
    private let titleFontSize: CGFloat = 16
    private let buttonHeight: CGFloat = 36

    private let stackView = UIStackView()
    private let underlineView = UIView()
    private var buttons: [UIButton] = []
    private var underlineLeadingConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!

    private(set) var selectedIndex = 0

    var onSelectionChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 尺寸變動 (旋轉 / parent resize) 時, 底線位置與寬度跟著重算.
        applyUnderlineGeometry(animated: false)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: buttonHeight)
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .systemGray6

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }

        underlineView.backgroundColor = .mainPeach
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underlineView)

        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            underlineView.heightAnchor.constraint(equalToConstant: underlineHeight),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineLeadingConstraint,
            underlineWidthConstraint
        ])

        refreshTitles()
    }

    // MARK: - Selection

    @objc private func buttonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        selectedIndex = newIndex
        refreshTitles()
        applyUnderlineGeometry(animated: true)
        onSelectionChanged?(newIndex)
    }

    private func refreshTitles() {
        for (index, button) in buttons.enumerated() {
            let isSelected = index == selectedIndex
            button.setTitleColor(isSelected ? .black : .systemGray, for: .normal)
            button.titleLabel?.font = .systemFont(
                ofSize: titleFontSize,
                weight: isSelected ? .bold : .regular
            )
        }
    }

    private func applyUnderlineGeometry(animated: Bool) {
        guard !buttons.isEmpty, bounds.width > 0 else { return }
        let segmentWidth = bounds.width / CGFloat(buttons.count)
        let width = segmentWidth * underlineWidthRatio
        let leading = segmentWidth * CGFloat(selectedIndex) + (segmentWidth - width) / 2

        underlineLeadingConstraint.constant = leading
        underlineWidthConstraint.constant = width

        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
}
