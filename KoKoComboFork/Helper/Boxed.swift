//
//  Boxed.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/18.
//

import Foundation

@propertyWrapper
class Boxed<T> {
    typealias Listener = (T) -> Void
    
    private var listeners: [Listener] = []
    
    var wrappedValue: T {
        didSet {
            listeners.forEach { listener in
                listener(wrappedValue)
            }
        }
    }
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    var projectedValue: Boxed<T> {
        return self
    }
    
    func bind(_ listener: @escaping Listener) {
        self.listeners.append(listener)
        listener(wrappedValue)
    }
}
