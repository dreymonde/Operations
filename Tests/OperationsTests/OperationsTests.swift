//
//  OperationsTests.swift
//  Operations
//
//  Created by Oleg Dreyman on 3/6/18.
//  Copyright © 2018 Operations. All rights reserved.
//

import Foundation
import XCTest
import Operations

class AsyncPutOperation : AsyncOperation {
    
    let number: Int
    let put: (Int) -> ()
    
    init(number: Int, put: @escaping (Int) -> ()) {
        self.number = number
        self.put = put
        super.init()
        self.name = "put-\(number)"
    }
    
    deinit {
        print("Deinit", name ?? "UNK")
    }
    
    override func execute() {
        print(number, "Running")
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) {
            guard !self.isCancelled else {
                self.finish()
                return
            }
            self.put(self.number)
            self.finish()
        }
    }
    
    override func willFinish() {
        print(number, "Finishing...")
    }
    
    override func didFinish() {
        print(number, "Finished")
    }
    
}

class OperationsTests: XCTestCase {
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //// XCTAssertEqual(Operations().text, "Hello, World!")
    }
    
    func testArray() {
        var ar: [Int] = []
        let queue = CustomOperationQueue()
            .logging()
        let put1 = AsyncPutOperation(number: 1, put: { ar.append($0) })
        put1.completionBlock = {
            print("Block 1")
        }
        let put2 = AsyncPutOperation(number: 2, put: { ar.append($0) })
        let obsF = put1.observe(\.isFinished, options: [.old, .new]) { (_, change) in
            print("OP1", "isFinished", change.oldValue!, change.newValue!)
        }
        let obsE = put1.observe(\.isExecuting, options: [.old, .new]) { (_, change) in
            print("OP1", "isExecuting", change.oldValue!, change.newValue!)
        }
        let obsC = put1.observe(\.isCancelled, options: [.old, .new]) { (_, change) in
            print("OP1", "isCancelled", change.oldValue!, change.newValue!)
        }
        put2.addDependency(put1)
        let obsR = put2.observe(\.isReady, options: [.old, .new]) { (_, change) in
            print("OP2", "isReady", change.oldValue!, change.newValue!)
        }
        unwarn(obsF, obsE, obsC, obsR)
        let expectation = self.expectation(description: "waiting on put2")
        put2.completionBlock = {
            print(ar)
            expectation.fulfill()
        }
        queue.addOperation(put1)
        queue.addOperation(put2)
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(ar, [1, 2])
    }
    
    func testAsyncBlock() {
        let queue = CustomOperationQueue()
            .logging()
        var str: String?
        let block = AsyncBlockOperation { finish in
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2, execute: {
                str = "Hey"
                finish()
            })
        }
        let expectation = self.expectation(description: "block")
        block.completionBlock = {
            expectation.fulfill()
        }
        queue.addOperation(block)
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(str, "Hey")
    }
    
    static var allTests = [
        ("testExample", testExample),
    ]
}

func unwarn(_ obj: Any...) {
    return
}
