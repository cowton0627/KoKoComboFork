//
//  ScenarioViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/18.
//

import UIKit

/// 三種 scenario 導向 VC
class ScenarioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
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
    
    
}
