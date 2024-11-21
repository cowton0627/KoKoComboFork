//
//  FriendsViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/8.
//

import UIKit

/// 好友呈現主頁
class FriendsViewController: UIViewController {
    
    var scenario: Int?
    
    private enum Constants {
//        static let segmentedControlHeight: CGFloat = 44
        static let underlineViewHeight: CGFloat = 4
        static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
    }
    
    // MARK: - Properties
    private let goodFriends = "好友"
    private let chatChat = "聊天"
    
    private let hintText = "邀請你成為好友 : )"
    
    private let atmImage = UIImage(
        named: "icNavPinkWithdraw")?.withRenderingMode(.alwaysOriginal)
    private let withdrawImage = UIImage(
        named: "icNavPinkTransfer")?.withRenderingMode(.alwaysOriginal)
    private let scanImage = UIImage(
        named: "icNavPinkScan")?.withRenderingMode(.alwaysOriginal)
    
    private let avatar = UIImage(named: "imgFriendsList")
    private let accept = UIImage(named: "btnFriendsAgree")
    private let reject = UIImage(named: "btnFriendsDelet")
    
    private var viewModel: UserViewModel!
    private var invitationListView: InvitationListView!
    private var customSegmentedView: CustomSegmentedView!
    
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
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    // The underline view below the segmented control
    private lazy var bottomUnderlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = UIColor.mainPeach
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()
    
    // MARK: - IBOutlet
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var kokoIDLabel: UILabel!
    @IBOutlet weak var remindImgView: UIView!

    @IBOutlet weak var friendsContainerView: UIView!
    @IBOutlet weak var chatContainerView: UIView!

    @IBOutlet weak var headerViewConstraint: NSLayoutConstraint!
    
    // MARK: - Life Cycle
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let childVC = segue.destination as? FriendsDetailViewController {
            childVC.scenario = scenario
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let statusBarHeight = UIApplication.shared.statusBarFrame.height
//        print("Status Bar Height: \(statusBarHeight)")  // 54
//        print(navigationController?.navigationBar.bounds) // 96
        
        setupNavigationBar()
        
        setupCustomSegmentedView()
        handleSegmentSelectionChange(to: 0)
        
//        setupSegmentedConstraint()
//        updateSegmentView()
                
        setupViewModel()
        
        if let scenario = scenario,
            scenario == 3 {
            setupInvitationList(with: viewModel)
        }
        
        viewModel.$userData.bind { userData in
            DispatchQueue.main.async {
                self.userNameLabel.text = userData?.name
                self.kokoIDLabel.text = userData?.kokoid
                self.remindImgView.isHidden = true
            }
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        updateUnderlineWidth()
//        updateSegmentedUnderLinePosition()
        
        if let scenario = scenario,
           scenario == 3 {
//            headerViewConstraint.constant = invitationView.frame.height + 150
            headerViewConstraint.constant = invitationListView.frame.height + 150
        }

    }
    
    // MARK: - IBAction
    @IBAction func kokoIDLabelTapped(_ sender: UITapGestureRecognizer) {
        print("kokoIDLabelTapped")
    }
    
    
    // MARK: - Private Func
    private func setupViewModel() {
        viewModel = UserViewModel(scenario: scenario)
    }
    
    private func setupInvitationList(with viewModel: UserViewModel) {
        invitationListView = InvitationListView(
            friends: viewModel.friendsList,
            avatar: avatar,
            acceptImage: accept,
            rejectImage: reject
        )

        invitationListView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(invitationListView)

        NSLayoutConstraint.activate([
            invitationListView.topAnchor.constraint(
                equalTo: kokoIDLabel.bottomAnchor, constant: 20),
            invitationListView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            invitationListView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    
    private func updateSegmentView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            friendsContainerView.isHidden = false
            chatContainerView.isHidden = true
        } else {
            friendsContainerView.isHidden = true
            chatContainerView.isHidden = false
        }
    }
    
    private func setupCustomSegmentedView() {
        
        customSegmentedView = CustomSegmentedView()
        customSegmentedView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customSegmentedView)
        
        let safeLayoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            customSegmentedView.bottomAnchor.constraint(
                equalTo: headerView.bottomAnchor, constant: 0),
            customSegmentedView.leadingAnchor.constraint(
                equalTo: safeLayoutGuide.leadingAnchor, constant: 20),
            customSegmentedView.trailingAnchor.constraint(
                equalTo: safeLayoutGuide.trailingAnchor, constant: -255)
        ])
        
        customSegmentedView.onSelectionChanged = { [weak self] selectedIndex in
            self?.handleSegmentSelectionChange(to: selectedIndex)
        }
    }
    
    private func handleSegmentSelectionChange(to selectedIndex: Int) {
        switch selectedIndex {
        case 0: // 好友
            friendsContainerView.isHidden = false
            chatContainerView.isHidden = true
        case 1: // 聊天
            friendsContainerView.isHidden = true
            chatContainerView.isHidden = false
        default:
            break
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
                equalTo: headerView.bottomAnchor, constant: 0),
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
        guard segmentedControl.numberOfSegments > 0 else { return }
        // 計算 UISegmentedControl 的 1/4 寬度
        let segmentWidth = segmentedControl.frame.width / 4
        underlineWidthConstraint.constant = segmentWidth
    }
    
    // Change position of the underline
    private func updateSegmentedUnderLinePosition() {
        let padding = segmentedControl.frame.width / 8

        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex) + padding

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.leadingDistanceConstraint.constant = leadingDistance
//            self?.layoutIfNeeded()
        })
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
    private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateSegmentedUnderLinePosition()
        updateSegmentView()
    }
    
    @objc
    private func handleAcceptInvitation(_ sender: UIButton) {
        print("Accepted invitation from \(sender.tag)")
    }

    @objc
    private func handleRejectInvitation(_ sender: UIButton) {
        print("Rejected invitation from \(sender.tag)")
    }
    

}

extension FriendsViewController {
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
    
    @objc
    private func atmBtnTapped() {
        print("atmBtnTapped")
        self.navigationController?.popToRootViewController(animated: true)
//        self.navigationController?.viewControllers.remove(at: 0)
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
