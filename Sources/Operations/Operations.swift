//
//  Operations.swift
//  Operations
//
//  Created by Oleg Dreyman on 3/6/18.
//  Copyright © 2018 Operations. All rights reserved.
//

import Foundation

public final class AsyncBlockOperation : AsyncOperation {
    
    public typealias Finish = () -> Void
    let _run: (@escaping Finish) -> Void
    
    public init(run: @escaping (@escaping Finish) -> Void) {
        self._run = run
    }
    
    public override func execute() {
        _run({ self.finish() })
    }
    
}

public final class BlockOperation : AsyncOperation {
    
    private var block: () -> ()
    public init(block: @escaping () -> ()) {
        self.block = block
    }
    
    public override func execute() {
        block()
        finish()
    }
    
    public func addExecutionBlock(_ nextBlock: @escaping () -> ()) {
        let old = block
        block = {
            old()
            nextBlock()
        }
    }
    
}

extension OperationQueue {
    
    public convenience init(name: String?) {
        self.init()
        self.name = name
    }
    
    public func addOperations(_ ops: [Operation]) {
        for operation in ops {
            self.addOperation(operation)
        }
    }
    
}
