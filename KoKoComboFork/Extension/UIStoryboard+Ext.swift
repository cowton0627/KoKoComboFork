//
//  UIStoryboard+Ext.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/6.
//

import UIKit

extension UIStoryboard {
    
    /// 將 Storyboard 名稱集中管理
    enum BoardName: String {
        case LaunchScreen
        case Scenario
        case Main
        case Friend
    }
    
    convenience init(name: BoardName, bundle: Bundle? = nil) {
        self.init(name: name.rawValue, bundle: bundle)
    }
    
    static func bakeBoard(name: BoardName, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: name.rawValue, bundle: bundle)
    }
    
}

extension UIStoryboard {
    /// 直接用 Class name 建立 View Controller
    func instantiateVC<T: UIViewController>(withClass name: T.Type) -> T {
        guard let vc = self.instantiateViewController(withIdentifier: T.identifier) as? T else {
            fatalError("Unable to instantiate VC with identifier \(T.identifier)")
        }
        return vc
    }
    
    /// 直接用 Identifier 建立 View Controller
    func instantiateVC(withIdentifier identifier: String) -> UINavigationController {
        guard let VC = self.instantiateViewController(withIdentifier: identifier) as? UINavigationController else {
            fatalError("Unable to instantiate VC with identifier \(identifier)")
        }
        return VC
    }
}
