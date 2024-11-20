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
    
    private let invitationView = UIView()
    
    private var invitationStackView = UIStackView()
    
    private var invitationListView: InvitationListView!
    
    private var viewModel: UserViewModel!

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
        setupSegmentedConstraint()
        updateSegmentView()
                
        if let scenario = scenario,
            scenario == 3 {
            setupInvitationList()
//            setupInvitationView(isHidden: false)
        } else {
//            setupInvitationView(isHidden: true)
        }
        
        
        setupViewModel()
        
        viewModel.$userName.bind { userName in
            DispatchQueue.main.async {
                self.userNameLabel.text = userName
                self.remindImgView.isHidden = true
            }
        }
        
        viewModel.$kokoID.bind { kokoID in
            DispatchQueue.main.async { self.kokoIDLabel.text = kokoID }
        }
        
        viewModel.$isInvitationViewHidden.bind { isHidden in
            DispatchQueue.main.async { self.invitationView.isHidden = isHidden }
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUnderlineWidth()
        updateSegmentedUnderLinePosition()
        
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
    
    private func setupInvitationList() {
        let staticFriends = [
            Friend(name: "彭安亭", status: 1, isTop: "0", fid: "001", updateDate: "1983/06/27"),
            Friend(name: "施君凌", status: 1, isTop: "0", fid: "002", updateDate: "1983/06/27")
        ]

        invitationListView = InvitationListView(
            friends: staticFriends,
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
//            invitationListView.bottomAnchor.constraint(
//                lessThanOrEqualTo: view.bottomAnchor, constant: -20) // 可選
        ])
    }
    
    private func setupInvitationView(isHidden: Bool) {
        invitationView.translatesAutoresizingMaskIntoConstraints = false
        invitationView.backgroundColor = .white
        invitationView.isHidden = isHidden
        self.view.addSubview(invitationView)
        
        invitationStackView.axis = .vertical
        invitationStackView.spacing = 10
        invitationStackView.translatesAutoresizingMaskIntoConstraints = false
        invitationView.addSubview(invitationStackView)

        NSLayoutConstraint.activate([
            invitationView.topAnchor.constraint(
                equalTo: kokoIDLabel.bottomAnchor, constant: 20),
            invitationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            invitationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            
            invitationStackView.topAnchor.constraint(equalTo: invitationView.topAnchor, constant: 10),
            invitationStackView.leadingAnchor.constraint(equalTo: invitationView.leadingAnchor, constant: 10),
            invitationStackView.trailingAnchor.constraint(equalTo: invitationView.trailingAnchor, constant: -10),
            invitationStackView.bottomAnchor.constraint(equalTo: invitationView.bottomAnchor, constant: -10)
        ])
        invitationView.backgroundColor = .clear
        
        // Static Data
        let staticFriends = [
            Friend(name: "彭安亭", status: 1, isTop: "0",
                   fid: "001", updateDate: "1983/06/27"),
            Friend(name: "施君凌", status: 1, isTop: "0",
                   fid: "002", updateDate: "1983/06/27")
        ]
        
        for friend in staticFriends {
            let cell = createInvitationCell(for: friend)
            invitationStackView.addArrangedSubview(cell)
        }
    }
    
    private func createInvitationCell(for friend: Friend) -> UIView {
        let cell = UIView()
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 8
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowRadius = 4
        cell.layer.shadowOffset = Constants.shadowOffset
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let imageView = UIImageView(image: avatar)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint =
        imageView.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = friend.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let hintLabel = UILabel()
        hintLabel.text = hintText
        hintLabel.font = UIFont.systemFont(ofSize: 14)
        hintLabel.textColor = .gray
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let acceptButton = UIButton(type: .system)
        acceptButton.setImage(accept, for: .normal)
        acceptButton.backgroundColor = .white
        acceptButton.tintColor = UIColor.mainPeach
        acceptButton.layer.cornerRadius = 20
        acceptButton.tag = Int(friend.fid) ?? 0
        acceptButton.addTarget(self, action: #selector(handleAcceptInvitation(_:)),
                               for: .touchUpInside)
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        let rejectButton = UIButton(type: .system)
        rejectButton.setImage(reject, for: .normal)
        rejectButton.backgroundColor = .white
        rejectButton.tintColor = UIColor.systemGray5
        rejectButton.layer.cornerRadius = 20
        rejectButton.tag = Int(friend.fid) ?? 0
        rejectButton.addTarget(self, 
                               action: #selector(handleRejectInvitation(_:)),
                               for: .touchUpInside)
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        
        let vStack = UIStackView(
            arrangedSubviews: [nameLabel, hintLabel]
        )
        vStack.axis = .vertical
        vStack.spacing = 5
        vStack.translatesAutoresizingMaskIntoConstraints = false
                
        let hStack = UIStackView(
            arrangedSubviews: [imageView, vStack, acceptButton, rejectButton]
        )
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false

        cell.addSubview(hStack)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 60),
            heightConstraint,

            acceptButton.widthAnchor.constraint(equalToConstant: 40),
            acceptButton.heightAnchor.constraint(equalToConstant: 40),

            rejectButton.widthAnchor.constraint(equalToConstant: 40),
            rejectButton.heightAnchor.constraint(equalToConstant: 40),

            hStack.topAnchor.constraint(equalTo: cell.topAnchor, 
                                        constant: 10),
            hStack.leadingAnchor.constraint(equalTo: cell.leadingAnchor, 
                                            constant: 10),
            hStack.trailingAnchor.constraint(equalTo: cell.trailingAnchor,
                                             constant: -10),
            hStack.bottomAnchor.constraint(equalTo: cell.bottomAnchor, 
                                           constant: -10)
        ])
        
        cell.backgroundColor = .systemGray6
                        
        return cell
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
