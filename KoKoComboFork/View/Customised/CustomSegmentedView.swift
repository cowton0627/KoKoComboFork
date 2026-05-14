//
//  CustomSegmentedView.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/19.
//

import UIKit

class CustomSegmentedView: UIView {
    
    private let goodFriends = "好友"
    private let chatChat = "聊天"
    
    private let underlineViewHeight: CGFloat = 4

    private var leadingDistanceConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!

    private var segmentedControl: UISegmentedControl!
    private var underlineView: UIView!
    
    var onSelectionChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnderlineWidth()
        updateUnderLinePosition()
    }

    /// setup SegmentedControl and Underline view
    private func setupViews() {
        backgroundColor = .systemGray6
        tintColor = .clear
        
        segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.selectedSegmentTintColor = .clear
        
        segmentedControl.insertSegment(withTitle: goodFriends, at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: chatChat, at: 1, animated: true)
        
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemGray,
             .font: UIFont.systemFont(ofSize: 16, weight: .regular)],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black,
             .font: UIFont.systemFont(ofSize: 16, weight: .bold)],
            for: .selected
        )
        
        segmentedControl.addTarget(self,
                                   action: #selector(segmentedControlValueChanged),
                                   for: .valueChanged)
        
        underlineView = UIView()
        underlineView.backgroundColor = UIColor.mainPeach
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(segmentedControl)
        addSubview(underlineView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(
                equalTo: self.topAnchor),
            segmentedControl.leadingAnchor.constraint(
                equalTo: self.leadingAnchor),
            segmentedControl.centerXAnchor.constraint(
                equalTo: self.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(
                equalTo: self.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            underlineView.bottomAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor, constant: 5),
            underlineView.heightAnchor.constraint(
                equalToConstant: underlineViewHeight),
        ])
        
        leadingDistanceConstraint = underlineView.leadingAnchor.constraint(
            equalTo: segmentedControl.leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(
            equalToConstant: segmentedControl.frame.width / 4)
        
        NSLayoutConstraint.activate([
            leadingDistanceConstraint,
            underlineWidthConstraint
        ])
    }
    
    private func updateUnderlineWidth() {
        guard segmentedControl.numberOfSegments > 0 else { return }
        // 計算 UISegmentedControl 的 1/4 寬度
        let segmentWidth = segmentedControl.frame.width / 4
        underlineWidthConstraint.constant = segmentWidth
    }
    
    @objc
    private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateUnderLinePosition()
        onSelectionChanged?(segmentedControl.selectedSegmentIndex)
    }

    private func updateUnderLinePosition() {
        let padding = segmentedControl.frame.width / 8

        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex) + padding

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
            self?.layoutIfNeeded()
        })
    }
}
