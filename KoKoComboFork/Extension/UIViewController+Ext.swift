//
//  UIViewController+Ext.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/6.
//

import UIKit

extension UIViewController {
    static var identifier: String { return String(describing: self) }
}

extension UIViewController {
    /// 調用此 function，讓 View Controller 下的 Text Field 在鍵盤彈出時，點擊旁邊收鍵盤
    func hideKeyboardWhenTappedAround() {
        let tapAround: UITapGestureRecognizer =
        UITapGestureRecognizer(target: self,
                               action: #selector(UIViewController.dismissKeyboard))
        tapAround.cancelsTouchesInView = false
        view.addGestureRecognizer(tapAround)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func showDemoNotice(feature: String) {
        guard presentedViewController == nil else { return }

        let alert = UIAlertController(
            title: feature,
            message: "此流程不在目前作品集 Demo 的展示範圍。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "了解", style: .default))
        present(alert, animated: true)
    }
}
