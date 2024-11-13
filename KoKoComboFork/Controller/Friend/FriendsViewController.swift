//
//  FriendsViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/8.
//

import UIKit

class FriendsViewController: UIViewController {
    
//    private let atm = "icNavPinkWithdraw"
//    private let withdraw = "icNavPinkTransfer"
//    private let scan = "icNavPinkScan"
    
    private let atmImage = UIImage(named: "icNavPinkWithdraw")?.withRenderingMode(.alwaysOriginal)
    private let withdrawImage = UIImage(named: "icNavPinkTransfer")?.withRenderingMode(.alwaysOriginal)
    private let scanImage = UIImage(named: "icNavPinkScan")?.withRenderingMode(.alwaysOriginal)
    
    
    private let friendsView = UIView()
    private let chatView = UIView()
    
    private enum Constants {
        static let segmentedControlHeight: CGFloat = 44
        static let underlineViewColor: UIColor = .systemPink
        static let underlineViewHeight: CGFloat = 4
    }
    
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
//        UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        segmentedControl.tintColor = .clear
        segmentedControl.selectedSegmentTintColor = .clear

//        segmentedControl.selectedSegmentTintColor = UIColor.systemPink

        // Append segments
        segmentedControl.insertSegment(withTitle: "好友", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "聊天", at: 1, animated: true)

        // Select first segment by default
        segmentedControl.selectedSegmentIndex = 0

        // Change text color and the font of the NOT selected (normal) segment
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)],
                                                for: .normal)

        // Change text color and the font of the selected segment
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)],
                                                for: .selected)

        // Set up event handler to get notified when the selected segment changes
        segmentedControl.addTarget(self, 
                                   action: #selector(segmentedControlValueChanged),
                                   for: .valueChanged)

        // Return false because we will set the constraints with Auto Layout
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    // The underline view below the segmented control
    private lazy var bottomUnderlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = Constants.underlineViewColor
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()
    
    private lazy var leadingDistanceConstraint: NSLayoutConstraint = {
        return bottomUnderlineView.leftAnchor.constraint(
            equalTo: segmentedControl.leftAnchor,
            constant: 25
        )
    }()
    
    
    @IBOutlet weak var upView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        print("Status Bar Height: \(statusBarHeight)")  // 54
        print(navigationController?.navigationBar.bounds) // 96

        
        setupNavigationBar()
        
//        setupSegmentedControl()
//        setupViews()
//        updateView()
        
        setupSegmetedConstraint()
        
        Task {
            do {
                let resp = try await UserService.shared.getUserData()
                print(resp)
            } catch (let error) {
                print(error)
            }
        }

    }
    
    private func setupSegmetedConstraint() {
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

        // Constrain the underline view relative to the segmented control
        NSLayoutConstraint.activate([
            bottomUnderlineView.bottomAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor, constant: 5),
            bottomUnderlineView.heightAnchor.constraint(
                equalToConstant: Constants.underlineViewHeight),
            
            leadingDistanceConstraint,
            
            bottomUnderlineView.widthAnchor.constraint(
                equalToConstant: 25)
            
//            bottomUnderlineView.widthAnchor.constraint(
//                equalTo: segmentedControl.widthAnchor,
//                multiplier: 1 / CGFloat(segmentedControl.numberOfSegments))
        ])
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        changeSegmentedControlLinePosition()
    }

        // Change position of the underline
    private func changeSegmentedControlLinePosition() {
        let segmentIndex = CGFloat(segmentedControl.selectedSegmentIndex)
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex + 25

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
//            self?.layoutIfNeeded()
        })
    }
    
    private func setupSegmentedControl() {
        // 設置 UISegmentedControl
        segmentedControl.addTarget(self, 
                                   action: #selector(segmentedControlChanged(_:)),
                                   for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        // 佈局 SegmentedControl
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: upView.bottomAnchor, 
                                                  constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, 
                                                      constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -20)
        ])
    }
    
    private func setupViews() {
        // 設置好友視圖
        friendsView.backgroundColor = UIColor.systemBackground
        friendsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(friendsView)
        
        // 設置聊天視圖
        chatView.backgroundColor = UIColor.systemGray6
        chatView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatView)
        
        // 佈局兩個視圖
        NSLayoutConstraint.activate([
            friendsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,
                                             constant: 20),
            friendsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            chatView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,
                                          constant: 20),
            chatView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func updateView() {
        // 根據選擇的分頁顯示對應的視圖
        if segmentedControl.selectedSegmentIndex == 0 {
            friendsView.isHidden = false
            chatView.isHidden = true
        } else {
            friendsView.isHidden = true
            chatView.isHidden = false
        }
    }
    
    private func setupNavigationBar() {
//        // 左邊的第一個圖片按鈕
//        let atmButton = UIBarButtonItem(
//            image: atmImage,
//            style: .plain,
//            target: self,
//            action: #selector(atmBtnTapped)
//        )
//        
//        // 左邊的第二個圖片按鈕
//        let withdrawButton = UIBarButtonItem(
//            image: withdrawImage,
//            style: .plain,
//            target: self,
//            action: #selector(withdrawBtnTapped)
//        )
//        
//        // 將兩個左邊的按鈕設置為 `leftBarButtonItems`
//        navigationItem.leftBarButtonItems = [atmButton, withdrawButton]
//        
//        // 右邊的圖片按鈕
//        let scanButton = UIBarButtonItem(
//            image: scanImage,
//            style: .plain,
//            target: self,
//            action: #selector(scanBtnTapped)
//        )
//            
//        // 將右邊的按鈕設置為 `rightBarButtonItem`
//        navigationItem.rightBarButtonItem = scanButton
        // 左邊的第一個按鈕
            let atmButton = createBarButton(image: atmImage, action: #selector(atmBtnTapped))
        // 設置按鈕之間的間距
            let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            fixedSpace.width = 24  // 這裡可以調整按鈕之間的距離
            
            // 左邊的第二個按鈕
            let withdrawButton = createBarButton(image: withdrawImage, action: #selector(withdrawBtnTapped))
            
            // 設置左邊的按鈕
            navigationItem.leftBarButtonItems = [atmButton, fixedSpace, withdrawButton]
            
            // 右邊的按鈕
            let scanButton = createBarButton(image: scanImage, action: #selector(scanBtnTapped))
            navigationItem.rightBarButtonItem = scanButton
    }
    
    
    // 使用 UIButton 創建 UIBarButtonItem
    private func createBarButton(
        image: UIImage?, action: Selector
    ) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        // 控制按鈕的點擊範圍
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return UIBarButtonItem(customView: button)
    }
    
    
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

    

}
