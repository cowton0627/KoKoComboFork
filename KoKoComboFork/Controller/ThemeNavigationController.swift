//
//  ThemeNavigationController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/12.
//

import UIKit

class ThemeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    

    private func configureUI() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.configureWithOpaqueBackground()
        barAppearance.backgroundColor = .systemGray5
        barAppearance.shadowColor = .clear
        
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().standardAppearance = barAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
        } else {
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
        }
        
        
    }

}
