//
//  CustomTabBarController.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/5.
//

import UIKit

/// 登入後主畫面 Tab Bar Controller
class CustomTabBarController: UITabBarController {
    
    private let productsOffImgae = UIImage(named: "icTabbarProductsOff")?.withRenderingMode(.alwaysOriginal)
    private let friendsOnImgae = UIImage(named: "icTabbarFriendsOn")?.withRenderingMode(.alwaysOriginal)
    private let homeOffImgae = UIImage(named: "icTabbarHomeOff")?.withRenderingMode(.alwaysOriginal)
    private let manageOffImgae = UIImage(named: "icTabbarManageOff")?.withRenderingMode(.alwaysOriginal)
    private let settingOffImgae = UIImage(named: "icTabbarSettingOff")?.withRenderingMode(.alwaysOriginal)
    
    private let products = "錢錢"
    private let friends = "朋友"
    private let blank = ""
    private let manage = "記帳"
    private let setting = "設定"
    
    var scenario: Int?
    private var returnButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        delegate = self
        
        // 未選的文字顏色
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.gray],
            for: .normal
        )

        // 選中的文字顏色
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.mainPeach],
            for: .selected
        )
        
        let customTabBar = CustomTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
        
        // 設定 Child VC
        let mainVC = createViewController(message: products,
                                          image: productsOffImgae, 
                                          selectedImage: nil)
        let homeVC = createViewController(message: blank,
                                          image: homeOffImgae,
                                          selectedImage: nil)
        let manageVC  = createViewController(message: manage,
                                            image: manageOffImgae,
                                            selectedImage: nil)
        let settingsVC = createViewController(message: setting,
                                              image: settingOffImgae,
                                              selectedImage: nil)
        
        let navC = ThemeNavigationController()
        let storyboard = UIStoryboard(name: .Friend)
        let friendsVC = storyboard.instantiateVC(withClass: FriendsViewController.self)
        navC.addChild(friendsVC)
        
        friendsVC.tabBarItem = UITabBarItem(title: friends,
                                            image: friendsOnImgae,
                                            selectedImage: nil)
        
        
        if let scenario = scenario,
           let vc = navC.topViewController as? FriendsViewController {
            vc.scenario = scenario
        }
        
        self.viewControllers = [mainVC, navC, homeVC, manageVC, settingsVC]
        
        self.selectedIndex = 1
        setupReturnButton()
    }
    
    private func createViewController(message: String,
                                      image: UIImage?,
                                      selectedImage: UIImage?) -> UIViewController {

        let storyboard = UIStoryboard(name: .Main)
        let vc = storyboard.instantiateVC(withClass: ViewController.self)
        
        vc.genreMessage = message
        
        vc.tabBarItem = UITabBarItem(
            title: message,
            image: image,
            selectedImage: selectedImage
        )
        
        return vc
    }
    
    private func setupReturnButton() {
        returnButton = UIButton(type: .system)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.addTarget(self,
                               action: #selector(returnButtonTapped),
                               for: .touchUpInside)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.tinted()
            config.baseForegroundColor = .mainPeach
            config.baseBackgroundColor = .secondarySystemBackground
            config.cornerStyle = .capsule
            config.image = UIImage(systemName: "chevron.left")
            config.imagePadding = 6
            config.title = "返回"
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 12,
                bottom: 8,
                trailing: 14
            )
            returnButton.configuration = config
        } else {
            returnButton.setTitle("返回", for: .normal)
            returnButton.setTitleColor(.mainPeach, for: .normal)
            returnButton.backgroundColor = .secondarySystemBackground
            returnButton.layer.cornerRadius = 18
            returnButton.contentEdgeInsets = UIEdgeInsets(
                top: 8,
                left: 12,
                bottom: 8,
                right: 14
            )
        }
        
        returnButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        returnButton.layer.shadowColor = UIColor.black.cgColor
        returnButton.layer.shadowOpacity = 0.12
        returnButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        returnButton.layer.shadowRadius = 8
        
        view.addSubview(returnButton)
        
        NSLayoutConstraint.activate([
            returnButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            returnButton.bottomAnchor.constraint(
                equalTo: tabBar.topAnchor, constant: -12)
        ])
    }
    
    @objc
    private func returnButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension CustomTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {
        guard selectedViewController !== viewController else { return false }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let animationsWereEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        UIView.performWithoutAnimation {
            selectedViewController = viewController
            tabBar.layoutIfNeeded()
        }
        UIView.setAnimationsEnabled(animationsWereEnabled)
        CATransaction.commit()
        
        return false
    }
    
}
