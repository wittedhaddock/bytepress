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
        
        let val = try! UInt(UInt64.max).pack()
        
        let upval = try! BPMsgUnpack.unpack(val, breadcrumb: "")
        
    }
    
    func testBin8() {
        var bin : [UInt8] = [0xff, 0xcc, 0xbb, 0xaa, 0xdd, 0xf1]
        let a = try! bin.pack()
        
    }
        
    func testStringPack() {
        let string = "WHAt is tHIS"
        let stringValue = try! string.pack()
        let stringValue2 = try! BPMsgPack.pack(string)
        XCTAssert(stringValue == stringValue2)
        
    }
    
    func testFloatPack() {
        let floatValue = 1.0 as Float
        let packedValue = try! floatValue.pack()
        
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
