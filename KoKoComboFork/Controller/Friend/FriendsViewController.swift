//
//  FriendsViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/8.
//

import UIKit

/// 好友呈現主頁
class FriendsViewController: UIViewController {
    
    // MARK: - Properties
    var scenario: Int?
    
    private var isInvitationListExpanded: Bool = false
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
//    private var invitationListView: InvitationListView!
    private var invitationTableView: UITableView!
    private var customSegmentedView: CustomSegmentedView!
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        setupCustomSegmentedView()
        handleSegmentSelectionChanged(to: 0)
                
        setupViewModel()
        
        if let scenario = scenario,
            scenario == 3 {
//            setupInvitationList(with: viewModel)
            setupInvitationTableView()
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
        
        if let scenario = scenario,
           scenario == 3 {
//            headerViewConstraint.constant = invitationListView.frame.height + 120
            headerViewConstraint.constant = invitationTableView.frame.height + 120
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
    
    private func setupInvitationTableView() {
        invitationTableView = UITableView()
        invitationTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(invitationTableView)
        
        invitationTableView.dataSource = self
        invitationTableView.delegate = self
        invitationTableView.registerNibCell(InvitationListTableViewCell.self)
        
        invitationTableView.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            invitationTableView.topAnchor.constraint(
                equalTo: kokoIDLabel.bottomAnchor, constant: 20),
            invitationTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            invitationTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
//            // 给定高度, 兩倍 Cell
//            invitationTableView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
        invitationTableViewHeightConstraint =
        invitationTableView.heightAnchor.constraint(equalToConstant: 140)
        invitationTableViewHeightConstraint.isActive = true

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
        return viewModel.friendsList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: InvitationListTableViewCell.self, for: indexPath)
        cell.configue(with: viewModel, at: indexPath.row)
        
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate
extension FriendsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        isInvitationListExpanded.toggle()

        invitationTableViewHeightConstraint.constant = isInvitationListExpanded
            ? CGFloat(70) : 140

        UIView.animate(withDuration: 0.3) {
            tableView.reloadData()
            self.view.layoutIfNeeded()
        }
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

extension FriendsViewController: FriendsDetailViewControllerDelegate {
    
    func didStartSearching() {
        // 點選 searchbar, 畫面上推
        UIView.animate(withDuration: 0.3) {
            if self.scenario == 3 {
                self.invitationTableViewHeightConstraint.constant = 0
//                self.invitationTableView.isHidden = true
            }
            self.headerViewConstraint.constant = 0
            self.customSegmentedView.isHidden = true
            self.view.layoutIfNeeded()

        }
    }

    func didEndSearching() {
        // 停止搜尋, 畫面恢復
        UIView.animate(withDuration: 0.3) {
            self.headerViewConstraint.constant = 120
            if self.scenario == 3 {
                self.invitationTableViewHeightConstraint.constant = 140
//                self.invitationTableView.isHidden = false
            }
            self.customSegmentedView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
}

