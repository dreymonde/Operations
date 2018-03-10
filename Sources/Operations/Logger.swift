//
//  Logger.swift
//  Operations
//
//  Created by Олег on 10.03.2018.
//  Copyright © 2018 Operations. All rights reserved.
//

import Foundation

extension CustomOperationQueue {
    
    private enum LogEntry : String {
        case START
        case FINIS
        case ENQUE
        case CANCL
    }
    
    private func log(entry: LogEntry, operation: Operation) {
        let queueName = (self.name ?? "unnamed")
        let opName = operation.name ?? "UNK"
        let address = unsafeBitCast(operation, to: Int.self)
        let formattedPointer = String(format: "%p", address)
        print("(OPS) [\(queueName)] \(entry.rawValue) \(opName) (\(formattedPointer))")
    }
    
    public func logging(shouldLog: @escaping (Operation) -> Bool = { _ in true }) -> CustomOperationQueue {
        var kvos: Set<NSKeyValueObservation> = []
        self.willEnqueue { (op) in
            guard shouldLog(op) else {
                return
            }
            let isExecuting = op.observe(\.isExecuting) { (operation, _) in
                if operation.isExecuting {
                    self.log(entry: .START, operation: operation)
                }
            }
            let isFinished = op.observe(\.isFinished) { (operation, _) in
                if operation.isFinished {
                    self.log(entry: .FINIS, operation: operation)
                }
            }
            let isCancelled = op.observe(\.isCancelled) { (operation, _) in
                if operation.isCancelled {
                    self.log(entry: .CANCL, operation: operation)
                }
            }
            for observation in [isExecuting, isFinished, isCancelled] {
                kvos.insert(observation)
            }
            self.log(entry: .ENQUE, operation: op)
        }
        return self
    }
    
}


