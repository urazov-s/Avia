//
//  Common.swift
//  avia.test
//
//  Created by Sergey Urazov on 23/02/2019.
//  Copyright © 2019 Sergey Urazov. All rights reserved.
//

import Foundation
import UIKit

@discardableResult
func with<T>(_ obj: T, do: (T) throws -> Void) rethrows -> T {
    try `do`(obj)
    return obj
}

enum Result<T> {
    case success(T)
    case failure(Error)

    func map<E>(_ mapping: (T) throws -> E) rethrows -> Result<E> {
        switch self {
        case .failure(let error):
            return .failure(error)
        case .success(let value):
            return .success(try mapping(value))
        }
    }
}

enum CastingError: Error {
    case invalidCasting(value: Any?, dstType: String)
}

func cast<T>(_ obj: Any?) throws -> T! {
    if let obj = obj as? T {
        return obj
    } else {
        throw CastingError.invalidCasting(value: obj, dstType: String(describing: T.self))
    }
}

func cast<T>(_ obj: Any?, default: T) -> T! {
    if let obj = obj as? T {
        return obj
    } else {
        return `default`
    }
}

protocol JSONObject {}
extension Dictionary: JSONObject where Key == String {}
extension Array: JSONObject {}
extension NSDictionary: JSONObject {}
extension NSArray: JSONObject {}

protocol Cancellable {
    func cancel()
}

struct PseudoCancellable: Cancellable {
    func cancel() {}
}

final class ThrottlingValue<T: Equatable> {
    private let delay: TimeInterval
    private let onChange: (T) -> Void

    private var lock = pthread_rwlock_t()
    private var _value: T
    var value: T {
        get {
            pthread_rwlock_rdlock(&lock)
            defer { pthread_rwlock_unlock(&lock) }
            return _value
        }
        set {
            pthread_rwlock_wrlock(&lock)
            defer { startTimer() }
            defer { pthread_rwlock_unlock(&lock) }
            _value = newValue
        }
    }

    private weak var timer: Timer?
    private var lastReportedValue: T?

    private func startTimer() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            let newTimer = Timer.scheduledTimer(withTimeInterval: self.delay, repeats: false) { timer in
                let valueToReport = self.value
                if valueToReport != self.lastReportedValue {
                    self.lastReportedValue = valueToReport
                    self.onChange(self.value)
                }
            }
            self.timer = newTimer
        }
    }

    init(initialValue: T, delay: TimeInterval, onChange: @escaping (T) -> Void) {
        self._value = initialValue
        self.delay = delay
        self.onChange = onChange
        pthread_rwlock_init(&lock, nil)
    }
}

private class WeakTarget: NSObject {
    private(set) weak var target: AnyObject?
    let selector: Selector

    static let triggerSelector = #selector(WeakTarget.timerDidTrigger(parameter:))

    init(_ target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    @objc
    private func timerDidTrigger(parameter: Any) {
        _ = self.target?.perform(self.selector, with: parameter)
    }
}

extension CADisplayLink {
    convenience init(weakTarget: AnyObject, selector: Selector) {
        self.init(target: WeakTarget(weakTarget, selector: selector), selector: WeakTarget.triggerSelector)
    }
}

func factorial(val: Int) -> Int {
    return (1...max(val, 1)).reduce(1, *)
}
