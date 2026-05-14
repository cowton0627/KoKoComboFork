//
//  Boxed.swift
//  KoKoComboFork
//
//  Created by cowton0627 on 2024/11/18.
//

import Foundation

@propertyWrapper
final class Boxed<T> {
    typealias Listener = (T) -> Void

    private let lock = NSLock()
    private var listeners: [UUID: Listener] = [:]
    private var _value: T

    var wrappedValue: T {
        get {
            lock.lock(); defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            _value = newValue
            let snapshot = Array(listeners.values)
            lock.unlock()

            notify(snapshot, with: newValue)
        }
    }

    init(wrappedValue: T) {
        self._value = wrappedValue
    }

    var projectedValue: Boxed<T> {
        return self
    }

    @discardableResult
    func bind(_ listener: @escaping Listener) -> BoxedToken {
        let id = UUID()
        lock.lock()
        listeners[id] = listener
        let currentValue = _value
        lock.unlock()

        notify([listener], with: currentValue)

        return BoxedToken { [weak self] in
            self?.removeListener(id: id)
        }
    }

    private func removeListener(id: UUID) {
        lock.lock(); defer { lock.unlock() }
        listeners.removeValue(forKey: id)
    }

    private func notify(_ listeners: [Listener], with value: T) {
        if Thread.isMainThread {
            for listener in listeners { listener(value) }
        } else {
            DispatchQueue.main.async {
                for listener in listeners { listener(value) }
            }
        }
    }
}

final class BoxedToken {
    private let lock = NSLock()
    private var cancelHandler: (() -> Void)?

    init(_ cancel: @escaping () -> Void) {
        self.cancelHandler = cancel
    }

    func cancel() {
        lock.lock()
        let handler = cancelHandler
        cancelHandler = nil
        lock.unlock()
        handler?()
    }
}
