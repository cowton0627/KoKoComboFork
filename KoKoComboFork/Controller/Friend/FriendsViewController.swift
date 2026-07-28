//
//  FriendsViewController.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/8.
//

import UIKit

/// 好友呈現主頁
class FriendsViewController: UIViewController {
    
    // MARK: - Properties
    var scenario: Int?
    
    private var invitationTableViewHeightConstraint: NSLayoutConstraint!

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
    private let friendsViewModel = FriendsViewModel()
    private var invitationTableView: UITableView!
    private var invitationHeaderView: UIStackView!
    private var invitationCountLabel: UILabel!
    private var invitationToggleButton: UIButton!
    private var remainingInvitationsLabel: UILabel!
    private var customSegmentedView: CustomSegmentedView!
    private var lastInvitationItems: [Friend] = []
    
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
            childVC.delegate = self
            childVC.viewModel = friendsViewModel
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        setupCustomSegmentedView()
        handleSegmentSelectionChanged(to: 0)

        setupViewModel()
        setupInvitationTableView()

        viewModel.$userData.bind { [weak self] userData in
            DispatchQueue.main.async {
                guard let self = self, let userData = userData else { return }
                self.userNameLabel.text = userData.name
                self.kokoIDLabel.text = userData.kokoid
                self.remindImgView.isHidden = true
            }
        }

        viewModel.$state.bind { [weak self] state in
            DispatchQueue.main.async {
                self?.apply(state)
            }
        }

        friendsViewModel.$state.bind { [weak self] state in
            guard let self = self else { return }
            let items = state.invitationItems
            self.viewModel.updateInvitationCount(items.count)
            self.applyInvitationUpdate(items)
        }
    }

    private func applyInvitationUpdate(_ newItems: [Friend]) {
        let old = lastInvitationItems
        lastInvitationItems = newItems

        guard let tableView = invitationTableView else { return }

        let newFids = Set(newItems.map(\.fid))
        let removedIndexPaths = old.enumerated().compactMap { offset, friend -> IndexPath? in
            newFids.contains(friend.fid) ? nil : IndexPath(row: offset, section: 0)
        }

        let isPureRemoval =
            !removedIndexPaths.isEmpty
            && old.count - removedIndexPaths.count == newItems.count
            && old.filter { newFids.contains($0.fid) }.map(\.fid) == newItems.map(\.fid)

        if isPureRemoval {
            tableView.performBatchUpdates {
                tableView.deleteRows(at: removedIndexPaths, with: .fade)
            }
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - IBAction
    @IBAction func kokoIDLabelTapped(_ sender: UITapGestureRecognizer) {
        showDemoNotice(feature: "設定 KOKO ID")
    }
    
    
    // MARK: - Private Func
    private func setupViewModel() {
        viewModel = UserViewModel()
    }
    
    private func apply(_ state: FriendsOverviewState) {
        headerViewConstraint.constant = CGFloat(state.headerHeight)
        customSegmentedView.isHidden = state.isSegmentedControlHidden
        invitationHeaderView.isHidden = state.invitationCount == 0
        invitationCountLabel.text = "好友邀請（\(state.invitationCount)）"
        invitationCountLabel.accessibilityLabel = "好友邀請，共 \(state.invitationCount) 位"
        invitationToggleButton.isHidden = state.isInvitationToggleHidden
        invitationToggleButton.setTitle(
            state.isInvitationListExpanded ? "收合" : "展開",
            for: .normal
        )
        invitationToggleButton.accessibilityValue =
            state.isInvitationListExpanded ? "已展開" : "已收合"
        invitationToggleButton.accessibilityHint =
            state.isInvitationListExpanded ? "點兩下收合邀請列表" : "點兩下展開邀請列表"
        remainingInvitationsLabel.text = "還有 \(state.remainingInvitationCount) 位邀請"
        remainingInvitationsLabel.accessibilityLabel =
            "還有 \(state.remainingInvitationCount) 位邀請未顯示"
        remainingInvitationsLabel.isHidden = state.remainingInvitationCount == 0
        invitationTableView.isScrollEnabled = state.remainingInvitationCount > 0
        invitationTableView.showsVerticalScrollIndicator =
            state.remainingInvitationCount > 0
        
        if invitationTableViewHeightConstraint != nil {
            invitationTableViewHeightConstraint.constant = CGFloat(state.invitationListHeight)
        }
    }
    
    private func setupInvitationTableView() {
        invitationCountLabel = UILabel()
        invitationCountLabel.font = UIFontMetrics(forTextStyle: .subheadline)
            .scaledFont(for: .systemFont(ofSize: 14, weight: .semibold))
        invitationCountLabel.adjustsFontForContentSizeCategory = true
        invitationCountLabel.textColor = .label
        invitationCountLabel.accessibilityIdentifier = "invitation.count"

        invitationToggleButton = UIButton(type: .system)
        invitationToggleButton.titleLabel?.font = UIFontMetrics(forTextStyle: .footnote)
            .scaledFont(for: .systemFont(ofSize: 13, weight: .semibold))
        invitationToggleButton.titleLabel?.adjustsFontForContentSizeCategory = true
        invitationToggleButton.tintColor = .mainPeach
        invitationToggleButton.accessibilityIdentifier = "invitation.toggle"
        invitationToggleButton.addTarget(
            self,
            action: #selector(invitationToggleButtonTapped),
            for: .touchUpInside
        )

        invitationHeaderView = UIStackView(
            arrangedSubviews: [invitationCountLabel, invitationToggleButton]
        )
        invitationHeaderView.translatesAutoresizingMaskIntoConstraints = false
        invitationHeaderView.axis = .horizontal
        invitationHeaderView.alignment = .center
        invitationHeaderView.distribution = .equalSpacing
        view.addSubview(invitationHeaderView)

        invitationTableView = UITableView()
        invitationTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(invitationTableView)

        remainingInvitationsLabel = UILabel()
        remainingInvitationsLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingInvitationsLabel.font = .preferredFont(forTextStyle: .footnote)
        remainingInvitationsLabel.adjustsFontForContentSizeCategory = true
        remainingInvitationsLabel.textColor = .secondaryLabel
        remainingInvitationsLabel.textAlignment = .center
        remainingInvitationsLabel.accessibilityIdentifier = "invitation.remaining"
        view.addSubview(remainingInvitationsLabel)
        
        invitationTableView.dataSource = self
        invitationTableView.delegate = self
        invitationTableView.registerNibCell(InvitationListTableViewCell.self)
        invitationTableView.rowHeight = 70
        invitationTableView.separatorStyle = .none
        invitationTableView.accessibilityIdentifier = "invitation.list"
        
        invitationTableView.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            invitationHeaderView.topAnchor.constraint(
                equalTo: kokoIDLabel.bottomAnchor, constant: 8),
            invitationHeaderView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            invitationHeaderView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            invitationHeaderView.heightAnchor.constraint(equalToConstant: 24),

            invitationTableView.topAnchor.constraint(
                equalTo: invitationHeaderView.bottomAnchor, constant: 8),
            invitationTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            invitationTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),

            remainingInvitationsLabel.topAnchor.constraint(
                equalTo: invitationTableView.bottomAnchor),
            remainingInvitationsLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            remainingInvitationsLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            remainingInvitationsLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        invitationTableViewHeightConstraint =
        invitationTableView.heightAnchor.constraint(equalToConstant: 0)
        invitationTableViewHeightConstraint.isActive = true

    }

    @objc private func invitationToggleButtonTapped() {
        viewModel.toggleInvitationList()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
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
            self?.handleSegmentSelectionChanged(to: selectedIndex)
        }
    }
    
    private func handleSegmentSelectionChanged(to selectedIndex: Int) {
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
    
}

// MARK: - UITableViewDataSource
extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return friendsViewModel.invitationItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: InvitationListTableViewCell.self, for: indexPath)
        let friend = friendsViewModel.invitationItems[indexPath.row]
        cell.configue(with: friend)
        cell.onAccept = { [weak self] in
            self?.friendsViewModel.acceptInvitation(fid: friend.fid)
        }
        cell.onReject = { [weak self] in
            self?.friendsViewModel.rejectInvitation(fid: friend.fid)
        }

        return cell
    }
    
    
}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
    
    private func createBarButton(image: UIImage?,
                                 action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)

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
    
    @objc
    private func atmBtnTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func withdrawBtnTapped() {
        showDemoNotice(feature: "提款")
    }
    
    @objc
    private func scanBtnTapped() {
        showDemoNotice(feature: "掃碼")
    }

}

extension FriendsViewController: FriendsDetailViewControllerDelegate {
    
    func didStartSearching() {
        // 點選 searchbar, 畫面上推
        viewModel.startSearching()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()

        }
    }

    func didEndSearching() {
        // 停止搜尋, 畫面恢復
        viewModel.endSearching()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
