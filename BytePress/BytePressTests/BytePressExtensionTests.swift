//
//  BytePressExtensionTests.swift
//  BytePress
//
//  Created by James William Graham on 12/21/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import XCTest
import BytePress

class BytePressExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testUInt32Max() {
        let value = try! Int(Int32.max).pack()
        
        let value2 = try! BPMsgPack.pack(Int(Int32.max))
        
        
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
