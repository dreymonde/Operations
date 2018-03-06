//
//  AsyncOperation.swift
//  Operations
//
//  Created by Олег on 06.03.2018.
//  Copyright © 2018 Operations. All rights reserved.
//

import Foundation

open class AsyncOperation : Foundation.Operation {
        
    fileprivate final var _state: ThreadSafe<State> = ThreadSafe(.pending)
    
    public private(set) final var state: State {
        get {
            return _state.read()
        }
        set(nextState) {
            let currentState = _state.read()
            guard currentState != nextState else {
                return
            }
//            guard nextState != state else {
//                return
//            }
            let affectedKeys = currentState.keysAffected(byTransitingTo: nextState)
            for key in affectedKeys {
                willChangeValue(forKey: key)
            }
            _state.write { (st) in
                guard st != .finished else { return }
                assert(st.canTransition(to: nextState))
                st = nextState
            }
            for key in affectedKeys {
                didChangeValue(forKey: key)
            }
        }
    }
    
    public final override var isAsynchronous: Bool {
        return true
    }
    
    @objc public final override var isReady: Bool {
        return super.isReady || isCancelled
    }
    
    @objc public final override var isExecuting: Bool {
        return state == .executing
    }
    
    @objc public final override var isFinished: Bool {
        return state == .finished
    }
    
    public final override func start() {
        guard !isCancelled else {
            return finish()
        }
        guard !isFinished else {
            return
        }
        state = .executing
        run()
    }
    
    open func run() {
        return finish()
    }
    
    public final func finish() {
        guard !isFinished else {
            return
        }
        willFinish()
        state = .finished
        didFinish()
    }
    
    open func willFinish() {
        return
    }
    
    open func didFinish() {
        return
    }
    
    public final override func cancel() {
        super.cancel()
        didCancel()
    }
    
    open func didCancel() {
        return
    }
    
}

extension AsyncOperation {
    
    public enum State {
        case pending
        case executing
        case finished
        
        public func keysAffected(byTransitingTo nextState: State) -> [String] {
            switch (self, nextState) {
            case (.pending, .executing):
                return ["isExecuting"]
            case (.executing, .finished):
                return ["isExecuting", "isFinished"]
            case (.pending, .finished):
                return ["isFinished"]
            default:
                return []
            }
        }
        
        public func canTransition(to nextState: State) -> Bool {
            switch (self, nextState) {
            case (.pending, .executing),
                 (.executing, .finished),
                 (.pending, .finished):
                return true
            default:
                return false
            }
        }
    }
    
}

internal struct ThreadSafe<Value> {
    
    private var _value: Value
    private let queue = DispatchQueue(label: "thread-safety-queue", attributes: [.concurrent])
    
    init(_ value: Value) {
        self._value = value
    }
    
    func read() -> Value {
        return queue.sync { _value }
    }
    
    mutating func write(with modify: (inout Value) -> ()) {
        queue.sync(flags: .barrier) {
            modify(&_value)
        }
    }
    
    mutating func write(_ newValue: Value) {
        queue.sync(flags: .barrier) {
            _value = newValue
        }
    }
    
}
