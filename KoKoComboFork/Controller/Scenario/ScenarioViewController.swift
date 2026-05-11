//
//  ScenarioViewController.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/18.
//

import UIKit

/// 三種 scenario 導向 VC
class ScenarioViewController: UIViewController {
    
    private let optionButtonHeight: CGFloat = 64
    private let optionButtonWidth: CGFloat = 286
    private var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        setupNavigationBar()
        setupHeader()
        setupScenarioButtons()
    }
    
    @IBAction func scenarioButtonTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: .Scenario)
        let tabBarC = storyboard.instantiateVC(withClass: CustomTabBarController.self)
        
//        let tabBarC = CustomTabBarController()
//        tabBarC.modalPresentationStyle = .fullScreen
        
        // 選擇情境, 將情境傳遞至 CustomTabBarController
        switch sender.tag {
        case 0:
            tabBarC.scenario = 4
        case 1:
            tabBarC.scenario = 1
        case 2:
            tabBarC.scenario = 3
        default:
            tabBarC.scenario = -1
        }
        
        self.navigationController?.pushViewController(tabBarC, animated: true)
//        self.present(tabBarC, animated: true)
    }
    
    private func setupNavigationBar() {
        title = nil
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupHeader() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "選擇展示情境"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "點選下方卡片進入對應的 KOKO 朋友頁展示"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 48),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -48)
        ])
    }
    
    private func setupScenarioButtons() {
        view.subviews.compactMap { $0 as? UIButton }.forEach {
            $0.removeFromSuperview()
        }
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 22
        
        let scenarioButtons = [0, 1, 2].map { tag -> UIButton in
            let button = UIButton(type: .system)
            button.tag = tag
            button.addTarget(self,
                             action: #selector(scenarioButtonTapped(_:)),
                             for: .touchUpInside)
            return button
        }
        
        scenarioButtons.forEach { button in
            styleScenarioButton(button)
            stackView.addArrangedSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: optionButtonWidth),
                button.heightAnchor.constraint(equalToConstant: optionButtonHeight)
            ])
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor, constant: 56),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func styleScenarioButton(_ button: UIButton) {
        let title: String
        let subtitle: String
        
        switch button.tag {
        case 0:
            title = "無好友畫面"
            subtitle = "顯示空狀態與加好友入口"
        case 1:
            title = "只有好友列表"
            subtitle = "顯示好友列表與搜尋"
        case 2:
            title = "好友列表含邀請"
            subtitle = "顯示邀請卡片與好友列表"
        default:
            title = button.currentTitle ?? "展示情境"
            subtitle = ""
        }
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .label
            config.cornerStyle = .medium
            config.titleAlignment = .leading
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 18,
                bottom: 10,
                trailing: 18
            )
            config.image = UIImage(systemName: "chevron.right")
            config.imagePlacement = .trailing
            config.imagePadding = 12
            
            var titleAttributes = AttributeContainer()
            titleAttributes.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            config.attributedTitle = AttributedString(title, attributes: titleAttributes)
            
            var subtitleAttributes = AttributeContainer()
            subtitleAttributes.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            subtitleAttributes.foregroundColor = UIColor.secondaryLabel
            config.attributedSubtitle = AttributedString(subtitle, attributes: subtitleAttributes)
            
            button.configuration = config
            button.contentHorizontalAlignment = .fill
        } else {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            button.backgroundColor = .white
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        }
        
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
    }
    
}
