//
//  UITableView+Ext.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/18.
//

import UIKit

extension UITableViewCell {
    /// 增加 idenfifier 屬性，減少使用 String(describing: )，增加可讀性
    static var identifier: String { return String(describing: self) }
}

extension UITableView {
    // dequeue reusable UITableViewCell using class name
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: name.identifier) as? T else {
            fatalError("Couldn't find UITableViewCell for \(name.identifier))")
        }
        return cell
    }
    
    // dequeue reusable UITableViewCell using class name for indexPath
    func dequeueReusableCell<T: UITableViewCell>(withClass name: T.Type,
                                                 for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: name.identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(name.identifier)")
        }
        return cell
    }
}
