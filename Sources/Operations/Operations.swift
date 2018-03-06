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
