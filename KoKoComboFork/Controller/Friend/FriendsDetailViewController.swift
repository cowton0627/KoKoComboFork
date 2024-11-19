//
//  FriendsDetailViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/14.
//

import UIKit

//protocol FriendsDetailViewControllerDelegate: AnyObject {
//    
//}

/// 好友呈現詳細頁
class FriendsDetailViewController: UIViewController {
    
//    weak var delegate: FriendsDetailViewControllerDelegate?
    var scenario: Int?
    
    // MARK: - Properties
    private let linkedLabelText = "幫助好友更快找到你？設定 KOKO ID"
    private let linkedText = "設定 KOKO ID"
    
    // MARK: - IBOutlet
    @IBOutlet var labelCollection: [UILabel]!
    @IBOutlet weak var kokoFriendsImgView: UIImageView!
    @IBOutlet weak var addFriendsButton: CustomGradientButton!
    @IBOutlet weak var linkedLabel: UILabel!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet weak var addFriendsImgView: UIImageView!

    private let viewModel = FriendsViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        setupDelegation()
        hideHaveFriendsView()
        
        // 取回要呈現的 Item
        if let scenario = scenario {
            viewModel.retrieveCellItems(completion: { [self] in
                print(self.scenario ?? -1)
            }, scenario: scenario)
        }
        
        // 當初次 Item 改變時, 調整呈現的 View
        viewModel.$cellItems.bind { _ in
            let item = self.viewModel.cellItems            
            self.setupViews(isEmpty: item.isEmpty)
            
            self.reloadTableView()
        }
        
        // 當篩選 Item 改變時, 重整 Table View
        viewModel.$filteredItems.bind { _ in
            self.reloadTableView()
        }
    
     }
    
    // MARK: - IBAction
    @IBAction func addFriendsButtonTapped(_ sender: CustomGradientButton) {
        print("addFriendsButtonTapped")
    }
    
    
    // MARK: - Private Func
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.friendsTableView.reloadData()
        }
    }
    
    private func setupViews(isEmpty: Bool) {
        DispatchQueue.main.async {
            self.friendSearchBar.isHidden = isEmpty
            self.addFriendsImgView.isHidden = isEmpty
            self.kokoFriendsImgView.isHidden = !isEmpty
            self.labelCollection.forEach { label in
                label.isHidden = !isEmpty
            }
            self.addFriendsButton.isHidden = !isEmpty
            self.friendsTableView.isHidden = isEmpty
        }
    }
    
    private func setupDelegation() {
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendSearchBar.delegate = self
    }
    
    private func hideHaveFriendsView() {
        friendSearchBar.isHidden = true
        addFriendsImgView.isHidden = true
        friendsTableView.isHidden = true
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
        UITapGestureRecognizer(target: self, action: #selector(handleLinkTapped))
        linkedLabel.addGestureRecognizer(tapGesture)
    }
        
    // MARK: - Objc Func
    @objc 
    private func handleLinkTapped(_ gesture: UITapGestureRecognizer) {
        guard let text = linkedLabel.attributedText?.string else { return }
        let range = (text as NSString).range(of: linkedText)
        
        if gesture.didTapAttributedTextInLabel(label: linkedLabel, 
                                               inRange: range) {
            print("Link Tapped")
        }
    }
    
}

// MARK: - UITableViewDataSource
extension FriendsDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: FriendsTableViewCell.self, for: indexPath)
        cell.configure(with: viewModel, at: indexPath.row)
        
        return cell
    }
    
    
}

// MARK: - UITableViewDelegate
extension FriendsDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension FriendsDetailViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        viewModel.filterItems(with: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterItems(with: "")
        searchBar.resignFirstResponder()
    }
}
