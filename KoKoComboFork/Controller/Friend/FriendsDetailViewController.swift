//
//  FriendsDetailViewController.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/14.
//

import UIKit

protocol FriendsDetailViewControllerDelegate: AnyObject {
    func didStartSearching()
    func didEndSearching()
}

/// 好友呈現詳細頁
class FriendsDetailViewController: UIViewController {
    
    weak var delegate: FriendsDetailViewControllerDelegate?
    var scenario: Int?
    
    // MARK: - Properties
    private let linkedLabelText = "幫助好友更快找到你？設定 KOKO ID"
    private let linkedText = "設定 KOKO ID"
    
    var viewModel: FriendsViewModel!
    private let refreshControl = UIRefreshControl()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "找不到符合的好友"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - IBOutlet
    @IBOutlet var labelCollection: [UILabel]!
    
    @IBOutlet weak var kokoFriendsImgView: UIImageView!
    @IBOutlet weak var addFriendsButton: CustomGradientButton!
    @IBOutlet weak var linkedLabel: UILabel!
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var friendSearchBar: UISearchBar!
    @IBOutlet weak var addFriendsImgView: UIImageView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        setupLabel()
        setupDelegation()
        setupLoadingIndicator()
        setupNoResultsLabel()
        hideHaveFriendsView()

        // 取回要呈現的 Item
        if let scenario = scenario {
            viewModel.retrieveCellItems(completion: { [self] in
                print(self.scenario ?? -1)
            }, scenario: scenario)
        }

        // 當初次 Item 改變時, 調整呈現的 View
        viewModel.$cellItems.bind { [weak self] _ in
            guard let self = self else { return }
            let item = self.viewModel.cellItems
            self.setupViews(isEmpty: item.isEmpty)

            self.reloadTableView()
        }

        // 當篩選 Item 改變時, 重整 Table View 並更新無結果提示
        viewModel.$filteredItems.bind { [weak self] _ in
            guard let self = self else { return }
            self.reloadTableView()
            self.updateNoResultsVisibility()
        }

        // 載入 / 錯誤狀態
        viewModel.$loadState.bind { [weak self] state in
            DispatchQueue.main.async {
                self?.apply(state)
            }
        }

        // 設置下拉刷新
        setupRefreshControl()

     }
    
    // MARK: - IBAction
    @IBAction func addFriendsButtonTapped(_ sender: CustomGradientButton) {
        print("addFriendsButtonTapped")
    }
    
    
    // MARK: - Private Func
    private func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "載入中...")
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh),
                                 for: .valueChanged)
        friendsTableView.refreshControl = refreshControl
    }

    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNoResultsLabel() {
        view.addSubview(noResultsLabel)
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: friendsTableView.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: friendsTableView.centerYAnchor),
            noResultsLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            noResultsLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func apply(_ state: LoadState) {
        switch state {
        case .idle:
            break
        case .loading:
            if !refreshControl.isRefreshing {
                loadingIndicator.startAnimating()
            }
            noResultsLabel.isHidden = true
        case .loaded:
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            updateNoResultsVisibility()
        case .failed(let message):
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
            showErrorAlert(message: message)
        }
    }

    private func updateNoResultsVisibility() {
        let isSearching = !(friendSearchBar.text ?? "").isEmpty
        noResultsLabel.isHidden = !(isSearching
                                    && viewModel.filteredItems.isEmpty
                                    && !viewModel.cellItems.isEmpty)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "載入失敗",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "重試", style: .default) { [weak self] _ in
            guard let self = self, let scenario = self.scenario else { return }
            self.viewModel.retrieveCellItems(completion: {}, scenario: scenario)
        })
        alert.addAction(UIAlertAction(title: "關閉", style: .cancel))
        present(alert, animated: true)
    }

    
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
    
    @objc private func handleRefresh() {
        guard let scenario = scenario else { return }
        
        // 重新請求數據
        viewModel.retrieveCellItems(completion: { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }, scenario: scenario)
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
        cell.configure(with: viewModel.cellViewModel(at: indexPath.row))
        
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder() // 確保焦點已正確進入
        searchBar.setShowsCancelButton(true, animated: true)
        delegate?.didStartSearching()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        delegate?.didEndSearching()
    }

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        viewModel.filterItems(with: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterItems(with: "")
        searchBar.resignFirstResponder()
        noResultsLabel.isHidden = true
    }
    
}
