//
//  CustomOperationQueue.swift
//  Operations
//
//  Created by Олег on 06.03.2018.
//  Copyright © 2018 Operations. All rights reserved.
//

import Foundation

open class CustomOperationQueue : OperationQueue {
    
    private var willEnqueue: (Operation) -> Void = { _ in }
    private var didEnqueue: (Operation) -> Void = { _ in }
    open override func addOperation(_ op: Operation) {
        willEnqueue(op)
        super.addOperation(op)
        didEnqueue(op)
    }
    
    open override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        ops.forEach(willEnqueue)
        super.addOperations(ops, waitUntilFinished: wait)
        ops.forEach(didEnqueue)
    }
    
    open func willEnqueue(_ block: @escaping (Operation) -> ()) {
        let current = willEnqueue
        willEnqueue = { op in
            current(op)
            block(op)
        }
    }
    
    open func didEnqueue(_ block: @escaping (Operation) -> ()) {
        let current = didEnqueue
        didEnqueue = { op in
            current(op)
            block(op)
        }
    }
    
    private var willCancelAllOperations: () -> Void = { }
    private var didCancelAllOperations: () -> Void = { }
    open override func cancelAllOperations() {
        willCancelAllOperations()
        super.cancelAllOperations()
        didCancelAllOperations()
    }
    
    open func willCancelAllOperations(_ block: @escaping () -> ()) {
        let current = willCancelAllOperations
        willCancelAllOperations = {
            current()
            block()
        }
    }
    
    open func didCancelAllOperations(_ block: @escaping () -> ()) {
        let current = didCancelAllOperations
        didCancelAllOperations = {
            current()
            block()
        }
    }
    
}
