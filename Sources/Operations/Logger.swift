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
    
    private func log(entry: LogEntry, operationName: String?) {
        let queueName = (self.name ?? "unnamed")
        let opName = operationName ?? "UNK"
        print("(OPS) [\(queueName)] \(entry.rawValue) \(opName)")
    }
    
    public func logging(shouldLog: @escaping (Operation) -> Bool = { _ in true }) -> CustomOperationQueue {
        var kvos: Set<NSKeyValueObservation> = []
        self.willEnqueue { (op) in
            guard shouldLog(op) else {
                return
            }
            let isExecuting = op.observe(\.isExecuting) { (operation, _) in
                if operation.isExecuting {
                    self.log(entry: .START, operationName: operation.name)
                }
            }
            let isFinished = op.observe(\.isFinished) { (operation, _) in
                if operation.isFinished {
                    self.log(entry: .FINIS, operationName: operation.name)
                }
            }
            let isCancelled = op.observe(\.isCancelled) { (operation, _) in
                if operation.isCancelled {
                    self.log(entry: .CANCL, operationName: operation.name)
                }
            }
            for observation in [isExecuting, isFinished, isCancelled] {
                kvos.insert(observation)
            }
            self.log(entry: .ENQUE, operationName: op.name)
        }
        return self
    }
    
}


