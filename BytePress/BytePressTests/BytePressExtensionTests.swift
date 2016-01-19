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
    
    func testPack8BitInt() {
        let a = Int8.min
        let packed = try! a.pack()
        XCTAssert([0xd0, UInt8(unsafeBitCast(a, UInt8.self))] == packed, "8bit int \(a) must equal packed \(packed)")
    }
    
    func testPack16BitInt() {
        let a = Int16.min
        let packed = try! a.pack()
        XCTAssert([0xd1, 128, 0] == packed, "16bit int \(a) must equal packed \(packed)")
    }
    
    func testPack32BitInt() {
        let a = Int32.min
        let packed = try! a.pack()
        XCTAssert([0xd2, 128, 0, 0, 0] == packed, "32bit int \(a) must equal packed \(packed)")
    }
    
    func testPack64BitInt() {
        let a = Int64.min
        let packed = try! a.pack()
        XCTAssert([0xd3, 128, 0, 0, 0, 0, 0, 0, 0] == packed, "64bit int \(a) must equal packed \(packed)")
    }
    
    func testPack32BitFloat() {
        let a: Float32 = 5.0000
        let packed = try! a.pack()
        print(packed)
        exit(1)
        // XCTAssert([0xca, ])
    }
    
    func testPack64BitFloat() {
        let a: Double = 5.0
        let packed = try! a.pack()
        print(packed)
        exit(1)
    }
    
    func testFixStringPack() {
        let a = "abcdefghijklmnopqrstuvwxyz"
        let packed = try! a.pack()
        XCTAssert([UInt8(0b10100000 | a.utf8.count)] + [UInt8](a.utf8) == packed, "fixstring \(a) must equal packed \(packed)")
    }
    
    func testPack8BitString() {
        let a = String(count: Int(UInt8.max), repeatedValue: Character("a"))
        let packed = try! a.pack()
        XCTAssert([0xd9, UInt8(a.utf8.count)] + [UInt8](a.utf8) == packed, "8bit string \(a) must equal packed \(packed)")
    }
    
    func testPack16BitString() {
        let a = String(count: Int(UInt16.max), repeatedValue: Character("a"))
        let packed = try! a.pack()
        XCTAssert([0xda, 0xff, 0xff] + [UInt8](a.utf8) == packed, "16bit string \(a) must equal packed \(packed)")
    }
    
    func testPack32BitString() {
        //takes some time
        let a = String(count: Int(UInt16.max) + 1, repeatedValue: Character("a"))
        let packed = try! a.pack()
        XCTAssert([0xdb, 0, 1, 0, 0] + [UInt8](a.utf8) == packed, "32bit string \(a) must equal packed \(packed)")
    }
    
    func testBin8() {
        let a : [UInt8] = [0xff, 0xcc, 0xbb, 0xaa, 0xdd, 0xf1]
        let packed = try! a.pack()
        XCTAssert([0xc4, UInt8(a.count)] + a == packed, "8bit long byte array \(a) must equal packed \(packed)")
    }
    
    func testBin16() {
        var a: [UInt8] = [0xf0]
        for _ in 0..<UInt(UInt16.max) - 1 {
            a += [0xf0]
        }
        let packed = try! a.pack()
        XCTAssert([0xc5, 0xff, 0xff] + a == packed, "16bit long byte array \(a) must equal packed \(packed)")
    }
    
    func testBin32() {
        var a: [UInt8] = [0xf0]
        for _ in 0..<UInt(UInt16.max) {
            a += [0xf0]
        }
        let packed = try! a.pack()
        XCTAssert([0xc6, 0, 1, 0, 0] + a == packed, "32bit long byte array \(a) must equal packed \(packed)")
    }
        
    func testFixArrayPack() {
        let b = UInt(UInt32.max)
        let c = UInt(UInt16.max)
        let a = [0, 10, 20, b, c]
        let packed = try! a.pack()
        let mirrored = [UInt8(0b10010000 | a.count), 0, 10, 20] +  (try! UInt32(b).pack()) + (try! UInt16(c).pack())
        XCTAssert(mirrored == packed, "fixarray \(mirrored) must equal packed \(packed)")
    }
    
    func test16BitArrayPack() {
        var a = [0xff_ff]
        for i in 0...UInt(UInt8.max) {
            a += i % 2 == 0 ? [0xff_0f] : [0xf0]
        }
        let packed = try! a.pack()
        exit(1)
    }
    
    func test32BitArrayPack() {
        var a = [0xff_ff]
        for _ in 0...UInt(UInt16.max) {
            a += [0xfa]
        }
        let packed = try! a.pack()
        exit(1)
    }
    
    func testFixMapPack() {
        let a = Dictionary(dictionaryLiteral: ("a", "b"))
        let packed = try! a.pack()
        
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
