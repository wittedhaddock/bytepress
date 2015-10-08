//
//  BytePressTests.swift
//  BytePressTests
//
//  Created by James William Graham on 9/12/15.
//  Copyright (c) 2015 caffeine. All rights reserved.
//

import XCTest
import BytePress

class BytePressTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPackString() {
         let packedString = try? BPMsgPack.pack("don't pack me")
         print(packedString)
    }
    
    func testPackBool() {
        let packedBool = try? BPMsgPack.pack(false)
        print( "my bool \(packedBool)")
    }
    
    func testPackInt() {
        let packedInt = try? BPMsgPack.pack(Int(Int32.max))
        print("my packed int: \(packedInt)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
