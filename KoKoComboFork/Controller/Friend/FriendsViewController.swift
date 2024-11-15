//
//  FriendsViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/8.
//

import UIKit

class FriendsViewController: UIViewController {
    
    private enum Constants {
//        static let segmentedControlHeight: CGFloat = 44
        static let underlineViewColor: UIColor = .systemPink
        static let underlineViewHeight: CGFloat = 4
    }
    
    // MARK: - Properties
    private let goodFriends = "好友"
    private let chatChat = "聊天"
    
    private let atmImage = UIImage(
        named: "icNavPinkWithdraw")?.withRenderingMode(.alwaysOriginal)
    private let withdrawImage = UIImage(
        named: "icNavPinkTransfer")?.withRenderingMode(.alwaysOriginal)
    private let scanImage = UIImage(
        named: "icNavPinkScan")?.withRenderingMode(.alwaysOriginal)
    
    private var leadingDistanceConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Closure Properties
    // Container view of the segmented control
    private lazy var segmentedControlContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.tintColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    // Customised segmented control
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()

        // Remove background and divider colors
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.selectedSegmentTintColor = .clear
        
//        segmentedControl.layer.borderWidth = 0
//        segmentedControl.layer.borderColor = UIColor.clear.cgColor
//        segmentedControl.layer.masksToBounds = true

        // Append segments
        segmentedControl.insertSegment(withTitle: goodFriends, at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: chatChat, at: 1, animated: true)

        // Select first segment by default
        segmentedControl.selectedSegmentIndex = 0

        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemGray,
             .font: UIFont.systemFont(ofSize: 16, weight: .regular)],
            for: .normal)
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black,
             .font: UIFont.systemFont(ofSize: 16, weight: .bold)],
            for: .selected)

        // add segmentedControl action
        segmentedControl.addTarget(self,
                                   action: #selector(segmentedControlValueChanged),
                                   for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
//        for subview in segmentedControl.subviews {
//            subview.layer.cornerRadius = 0
//            subview.layer.masksToBounds = false
//        }
        return segmentedControl
    }()
    
    // The underline view below the segmented control
    private lazy var bottomUnderlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = Constants.underlineViewColor
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()
    
    // MARK: - IBOutlet
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var kokoIDLabel: UILabel!
    @IBOutlet weak var remindImgView: UIView!

    @IBOutlet weak var friendsContainerView: UIView!
    @IBOutlet weak var chatContainerView: UIView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height
//        print("Status Bar Height: \(statusBarHeight)")  // 54
//        print(navigationController?.navigationBar.bounds) // 96

        setupNavigationBar()
        setupSegmentedConstraint()
        updateView()
        
        
        Task {
            do {
                let resp = try await UserService.shared.getUserData()
                print(resp)
                
                if let userResp = resp.response?.first {
                    userNameLabel.text = userResp.name
                    kokoIDLabel.text = "KOKO ID：\(userResp.kokoid) 〉"
                    remindImgView.isHidden = true
                }
                
            } catch (let error) {
                print(error)
            }
        }
        
        
        Task {
            do {
                let resp = try await UserService.shared.getFriendsData()
                print(resp)
                
            } catch (let error) {
                print(error.localizedDescription)
            }
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUnderlineWidth()
        changeSegmentedControlLinePosition()
        
//        if #available(iOS 15.0, *) {
//            // 再次確保所有樣式被正確應用
//            segmentedControl.layer.cornerRadius = 0
//            segmentedControl.layer.masksToBounds = true
//            
//            // 更新所有子視圖的樣式
//            segmentedControl.subviews.forEach { subview in
//                subview.layer.cornerRadius = 0
//                subview.backgroundColor = .clear
//            }
//        }
    }
    
    // MARK: - Private Func
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            friendsContainerView.isHidden = false
            chatContainerView.isHidden = true
        } else {
            friendsContainerView.isHidden = true
            chatContainerView.isHidden = false
        }
    }
    
    private func setupSegmentedConstraint() {
        // Add subviews to the view hierarchy
        view.addSubview(segmentedControlContainerView)
        segmentedControlContainerView.addSubview(segmentedControl)
        segmentedControlContainerView.addSubview(bottomUnderlineView)

        // Constrain the container view to the view controller
        let safeLayoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmentedControlContainerView.bottomAnchor.constraint(
                equalTo: upView.bottomAnchor, constant: 0),
            segmentedControlContainerView.leadingAnchor.constraint(
                equalTo: safeLayoutGuide.leadingAnchor, constant: 20),
            segmentedControlContainerView.trailingAnchor.constraint(
                equalTo: safeLayoutGuide.trailingAnchor, constant: -255)
        ])

        // Constrain the segmented control to the container view
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(
                equalTo: segmentedControlContainerView.topAnchor),
            segmentedControl.leadingAnchor.constraint(
                equalTo: segmentedControlContainerView.leadingAnchor),
            segmentedControl.centerXAnchor.constraint(
                equalTo: segmentedControlContainerView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(
                equalTo: segmentedControlContainerView.centerYAnchor)
        ])

        leadingDistanceConstraint = bottomUnderlineView.leadingAnchor.constraint(
            equalTo: segmentedControl.leadingAnchor)
        underlineWidthConstraint = bottomUnderlineView.widthAnchor.constraint(
            equalToConstant: segmentedControl.frame.width / 4)

        // Constrain the underline view relative to the segmented control
        NSLayoutConstraint.activate([
            bottomUnderlineView.bottomAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor, constant: 5),
            bottomUnderlineView.heightAnchor.constraint(
                equalToConstant: Constants.underlineViewHeight),
            leadingDistanceConstraint,
            underlineWidthConstraint
        ])
    }
    
    private func updateUnderlineWidth() {
        // 計算 UISegmentedControl 的 1/4 寬度
        let segmentWidth = segmentedControl.frame.width / 4
        underlineWidthConstraint.constant = segmentWidth
    }
    
    // Change position of the underline
    private func changeSegmentedControlLinePosition() {
        let padding = segmentedControl.frame.width / 8

        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex) + padding

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
//            self?.layoutIfNeeded()
        })
    }
    
    private func setupNavigationBar() {
        // 左邊的第一個按鈕
        let atmButton = createBarButton(image: atmImage, 
                                        action: #selector(atmBtnTapped))
        // 設置按鈕之間的間距
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                         target: nil,
                                         action: nil)
        fixedSpace.width = 24
            
        // 左邊的第二個按鈕
        let withdrawButton = createBarButton(image: withdrawImage,
                                             action: #selector(withdrawBtnTapped))
            
        navigationItem.leftBarButtonItems = [atmButton, fixedSpace, withdrawButton]
            
        // 右邊的按鈕
        let scanButton = createBarButton(image: scanImage, 
                                         action: #selector(scanBtnTapped))
        navigationItem.rightBarButtonItem = scanButton
    }
        
    private func createBarButton(image: UIImage?,
                                 action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
//        button.setImage(image, for: .normal)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = image
            config.imagePadding = 0
            config.contentInsets = 
            NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            button.configuration = config
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)

        // 控制按鈕的點擊範圍
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
        return UIBarButtonItem(customView: button)
    }
    
    // MARK: Objc Func
    @objc
    private func atmBtnTapped() {
        print("atmBtnTapped")
    }
    
    @objc
    private func withdrawBtnTapped() {
        print("withdrawBtnTapped")
    }
    
    @objc
    private func scanBtnTapped() {
        print("scanBtnTapped")
    }

    @objc 
    private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()
        updateView()
    }
    

}
