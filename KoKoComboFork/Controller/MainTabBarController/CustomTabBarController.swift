//
//  CustomTabBarController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/5.
//

import UIKit

/// 登入後主畫面 Tab Bar Controller
class CustomTabBarController: UITabBarController {
    
//    private let icTabbarProductsOff = "icTabbarProductsOff"
//    private let icTabbarFriendsOn = "icTabbarFriendsOn"
//    private let icTabbarHomeOff = "icTabbarHomeOff"
//    private let icTabbarManageOff = "icTabbarManageOff"
//    private let icTabbarSettingOff = "icTabbarSettingOff"
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()        
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
        
//        self.tabBar.tintColor = UIColor.mainPeach // 選中時的顏色
//        self.tabBar.unselectedItemTintColor = UIColor.gray // 未選中時的顏色

        
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
        
//        let friendsVC = UIViewController()
//        friendsVC.view.backgroundColor = .cyan
//        friendsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
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
}
