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

    
    func testNil() {
    /*    let a = Int(nil as Int)
        a.pack()
        print(a)*/
    }
    
    func testTruePack() {
        let a = true
        let packed = try! a.pack()
        XCTAssert(packed == [0xc3])
    }
    
    func testFalsePack() {
        let a = false
        let packed = try! a.pack()
        XCTAssert(packed == [0xc2])
    }
    
    func testPackFixuint() {
        let a = (UInt8.max / 2) - 1
        let packed = try! a.pack()
        XCTAssert([a] == packed, "fixint \(a) must equal packed \(packed)")
    }
    
    func testPack8bitUInt() {
        let a = UInt8.max
        let packed = try! a.pack()
        XCTAssert([0xcc, a] == packed, "8bit int \(a) must equal packed \(packed)")
    }
    
    func testPack16bitUInt () {
        let a = UInt16.max
        let packed = try! a.pack()
        XCTAssert([0xcd, 0xff, 0xff] == packed, "16bit int \(a) must equal packed \(packed)")
    }
    
    func testPack32bitUInt() {
        let a = UInt32.max
        let packed = try! a.pack()
        XCTAssert([0xce, 0xff, 0xff, 0xff, 0xff] == packed, "32bit int \(a) must equal packed \(packed)")
    }
    
    func testPack64BitUInt() {
        let a = UInt64.max
        let packed = try! a.pack()
        XCTAssert([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff] == packed, "64bit int \(a) must equal packed \(packed)")
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
