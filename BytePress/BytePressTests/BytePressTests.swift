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
    
    func testArr8() {
       // let arr:Array<AnyObject>  = [0xffff, "b       o        b", false] as  //why do I have to cast here???
        let arr: Array<Any> = [0]
        let packedArr = try! BPMsgPack.pack(arr)
        
        
        let unpackedArr = try! BPMsgUnpack.unpack(packedArr, breadcrumb: "")
        
    }
    
    func testBin8() {
        let bin: [UInt8] = [0x9f, 0xff, 0x1f, 0xf]
        let packedBin = try! BPMsgPack.pack(bin)
        let unpacked = try! BPMsgUnpack.unpack(packedBin, breadcrumb: "")
        switch unpacked {
        case .BPData(let ct):
            if let binarr = ct as? [UInt8] {
                XCTAssert(bin == binarr, "\(unpacked) is not equal to \(bin)")
            }
        default:
            XCTAssert(false, "\(unpacked) is not equal to \(bin)")
        }
    }
    
    func testBin16() {
        var bin: [UInt8] = [0xff]
        for _ in 0..<UInt(UInt16.max) - 1 {
            bin += [0xff]
        }
        let packedBin = try! BPMsgPack.pack(bin)
        let unpackedBin = try! BPMsgUnpack.unpack(packedBin, breadcrumb: "")
        switch unpackedBin {
        case .BPData(let ct):
            if let binarr = ct as? [UInt8] {
                XCTAssert(bin == binarr, "\(unpackedBin) is not equal to \(bin)")
            }
            else {
                XCTAssert(false)
            }
        default:
            XCTAssert(false)
        }
    }

    func testBin32() {
        var bin: [UInt8] = [0xff]
        for _ in 0..<UInt(UInt16.max) {
            bin += [0xff]
        }
        let packedBin = try! BPMsgPack.pack(bin)
        let unpackedBin = try! BPMsgUnpack.unpack(packedBin, breadcrumb: "")
        switch unpackedBin {
        case .BPData(let ct):
            if let binarr = ct as? [UInt8] {
                XCTAssert(bin == binarr, "\(unpackedBin) is not equal to \(bin)")
            }
            else {
                XCTAssert(false)
            }
        default:
            XCTAssert(false)
        }

    }
    
    func testPackFixString() {
        let string = "don't fucking pack me"
        let packedString = try! BPMsgPack.pack(string)
        print(packedString)
        let unpacked = try! BPMsgUnpack.unpack(packedString, breadcrumb: "")
        switch unpacked{
        case .BPString(let s):
            XCTAssert(string == s)
        default:
            XCTAssert(false, "\(unpacked) is not equal to \(string)")
        }
    }
    
    func testPackStringOneByte() {
        let string = "asdfas9df8ajsd9f8ajsd9fajsdfoa4lofijafjap49f8jadfjaspdfipaw49af8hs98fhas9d8fhap9w8fh"
        let packedString = try! BPMsgPack.pack(string)
        print(packedString)
        let unpacked = try! BPMsgUnpack.unpack(packedString, breadcrumb: "")
        switch unpacked{
        case .BPString(let s):
            XCTAssert(string == s)
        default:
            XCTAssert(false, "\(unpacked) is not equal to \(string)")
        }
    }
    
    func testPackStringTwoByte() {
        var string:String = ""
        for _ in 1...UInt(UInt16.max) {
            string += "a"
        }
        let packedString = try! BPMsgPack.pack(string)
        print(packedString)
        let unpacked = try! BPMsgUnpack.unpack(packedString, breadcrumb: "")
        switch unpacked{
        case .BPString(let s):
            XCTAssert(string == s, "\(unpacked) is not equal to \(string)")
        default:
            XCTAssert(false, "\(unpacked) is not equal to \(string)")
        }
    }
    
    func testPackStringFourByte() {
        var string:String = ""
        for _ in 1...UInt(UInt16.max)+1 { //uint32.max is just too much
            string += "a"
        }
        let packedString = try! BPMsgPack.pack(string)
        print(packedString)
        let unpacked = try! BPMsgUnpack.unpack(packedString, breadcrumb: "")
        switch unpacked{
        case .BPString(let s):
            XCTAssert(string == s, "\(unpacked) is not equal to \(string)")
        default:
            XCTAssert(false, "\(unpacked) is not equal to \(string)")
        }
    }
    
    func testPackBool() {
        let packedBool = try? BPMsgPack.pack(false)
        print( "my bool \(packedBool)")
    }
    
    func testPackPositiveDouble() {
        let fl = 5000.5 //why does it default to 64 bit, when it can be represented as 32 bit?
        let packed = try! BPMsgPack.pack(fl)
        let unpacked = try! BPMsgUnpack.unpack(packed, breadcrumb: "")
        switch unpacked{
        case .BPDouble(let d):
            XCTAssert(d == fl)
        default:
            XCTAssert(false, "\(unpacked) is interesting")
        }
    }
    
    
    func testPackNegativeInt() {
        let min16 = -256 << 16
        let packedInt = try! BPMsgPack.pack(min16)
        print("my packed int: \(packedInt)")
        let unpackedInt = try! BPMsgUnpack.unpack(packedInt, breadcrumb: "")
        print("my unpacked int: \(unpackedInt)")
        switch unpackedInt{
        case .BPInteger(let i):
            XCTAssert(i == min16, "\(unpackedInt) does not equal \(min16)")
        default:
            XCTAssert(false, "what even is \(unpackedInt)")
        }
    }
    
    func testPackNegative8BitInt() {
        let negative8 = Int(UInt8.max)
        
        let packed = try! BPMsgPack.pack(negative8)
        let unpacked = try! BPMsgUnpack.unpack(packed, breadcrumb: "")
        
        let unpackedVersion = try! BPMsgUnpack.valueFromBytePressType(unpacked)

        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
