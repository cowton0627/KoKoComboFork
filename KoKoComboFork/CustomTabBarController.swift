//
//  CustomTabBarController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/5.
//

import UIKit

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
    private let manage = "記帳"
    private let setting = "設定"
    
    private let peachColor = UIColor(red: 247/255,
                                     green: 38/255,
                                     blue: 102/255,
                                     alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 未選中狀態的文字顏色
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.gray],
            for: .normal
        )

        // 選中狀態的文字顏色
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: peachColor],
            for: .selected
        )
        
//        self.tabBar.tintColor = peachColor // 選中時的顏色
//        self.tabBar.unselectedItemTintColor = UIColor.gray // 未選中時的顏色

        
        let customTabBar = CustomTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
        
        // 設定 Child VC
        let firstVC = UIViewController()
        firstVC.view.backgroundColor = .yellow
        firstVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        firstVC.tabBarItem = UITabBarItem(title: products,
                                          image: productsOffImgae,
                                          selectedImage: nil)
        
        let secondVC = UIViewController()
        secondVC.view.backgroundColor = .cyan
        secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        secondVC.tabBarItem = UITabBarItem(title: friends,
                                           image: friendsOnImgae,
                                           selectedImage: nil)
        
        let fifthVC = UIViewController()
        fifthVC.view.backgroundColor = .gray
        fifthVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 4)
        fifthVC.tabBarItem = UITabBarItem(title: "",
                                          image: homeOffImgae,
                                          selectedImage: nil)
        
        let thirdVC = UIViewController()
        thirdVC.view.backgroundColor = .red
        thirdVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 2)
        thirdVC.tabBarItem = UITabBarItem(title: manage,
                                          image: manageOffImgae,
                                          selectedImage: nil)
        
        let fourthVC = UIViewController()
        fourthVC.view.backgroundColor = .green
        fourthVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
        fourthVC.tabBarItem = UITabBarItem(title: setting,
                                           image: settingOffImgae,
                                           selectedImage: nil)
        
        self.viewControllers = [firstVC, secondVC, fifthVC, thirdVC, fourthVC]
        
        self.selectedIndex = 1
    }
}
