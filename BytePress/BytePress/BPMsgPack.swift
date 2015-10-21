//
//  BPMsgPack.swift
//  BytePress
//
//  Created by James William Graham on 9/12/15.
//  Copyright (c) 2015 caffeine. All rights reserved.
//



public class BPMsgPack {
    public class func pack(item: Any) throws -> [UInt8] {
        var bytes: [UInt8] = Array<UInt8>()
        
        switch item {
        case _ where item is String:
            try packString(item as! String, bytesReceivingPackage: &bytes)
        case _ where item is Bool:
            try packBool(item as! Bool, bytesReceivingPackage: &bytes)
        case _ where item is UInt:
            try packUInt(item as! UInt, bytesReceivingPackage: &bytes)
        case _ where item is Int:
            if let x = item as? Int {
                if x > 0 {
                    try packUInt(UInt(x), bytesReceivingPackage: &bytes)
                }
                else {
                    try packInt(item as! Int, bytesReceivingPackage: &bytes)
                }
            }
            else {
                throw BytePressError.BadMagic("something bizarre")
            }
        case _ where item is Float:
            try packUInt(UInt(unsafeBitCast(item as! Float, UInt32.self)), bytesReceivingPackage: &bytes, overridingHeaderBytes: [0xca])
        case _ where item is Double:
            try packUInt(UInt(unsafeBitCast(item as! Double, UInt64.self)), bytesReceivingPackage: &bytes, overridingHeaderBytes: [0xcb])
        default:
            throw BytePressError.BadMagic(item)
        }
        return bytes
    }
    
    private class func packBool(value: Bool, inout bytesReceivingPackage: [UInt8]) throws {
        guard bytesReceivingPackage.count < 1 else {
            throw BytePressError.ArrayOutOfBounds(0, bytesReceivingPackage.count)
        }
        bytesReceivingPackage.append(value ? 0xc3 : 0xc2)
    }
    
    private class func packUInt(value: UInt, inout bytesReceivingPackage: [UInt8], overridingHeaderBytes:[UInt8] = [0xc0]) throws {
        let headerByte: UInt8
        let strideLength: UInt
        switch value {
        case 0...UInt(UInt8.max)/2:
            bytesReceivingPackage = [UInt8(value)]
            return
        case 0...UInt(UInt8.max):
            bytesReceivingPackage = [0xcc, UInt8(value)]
            return
        case 0...UInt(UInt16.max):
            headerByte = 0xcd
            strideLength = 16 - 8
        case 0...UInt(UInt32.max):
            headerByte = 0xce
            strideLength = 32 - 8
        case 0..<UInt(UInt64.max):
            headerByte = 0xcf
            strideLength = 64 - 8
        default:
            headerByte = 0xc0
            strideLength = 0
        }
        
        bytesReceivingPackage = overridingHeaderBytes == [0xc0] ? [headerByte] : overridingHeaderBytes + strideLength.stride(through: 0, by: -8).map({ i in
            return UInt8(truncatingBitPattern: value >> i)
        })
    }
    private class func packInt(value: Int, inout bytesReceivingPackage: [UInt8]) throws {
        let headerByte: UInt8
        let strideLength: Int
        switch value{
        case -32..<0, 0...127:
            //fix ints
            bytesReceivingPackage = [UInt8(value)]
            return
        case Int(Int8.min)...Int(Int8.max):
            //single byte of data
            bytesReceivingPackage = [value < 0 ? 0xd0 : 0xcc, UInt8(value)]
            return
        case Int(Int16.min)...Int(Int16.max):
            headerByte = value < 0 ? 0xd1 : 0xcd
            strideLength = 8
        case Int(Int32.min)...Int(Int32.max):
            headerByte = value < 0 ? 0xd2 : 0xce
            strideLength = 32 - 8
        case Int(Int64.min)...Int(Int64.max):
            headerByte = value < 0 ? 0xd3 : 0xcf
            strideLength = 64 - 8
        default:
            strideLength = 0
            headerByte = 0xc0
        }
        bytesReceivingPackage = [headerByte] + strideLength.stride(through: 0, by: -8).map({ i in
            return UInt8(truncatingBitPattern: (-value >> i))
        })

    }
    
    private class func packString(string: String, inout bytesReceivingPackage: [UInt8]) throws  {
        //TODO error handling for counts bigger than 255
        let headerBytes: [UInt8]
        let count = UInt(string.utf8.count)
        switch count {
        case _ where count <= 0x1f:
            headerBytes = [0b10100000 | UInt8(count)]
            bytesReceivingPackage = headerBytes + string.utf8
            return
        case _ where count <= 0xff:
            headerBytes = [0xd9]
            bytesReceivingPackage = headerBytes + [UInt8(count)] + string.utf8
            return
        case _ where count <= 0xff_ff:
            try! packUInt(count, bytesReceivingPackage: &bytesReceivingPackage, overridingHeaderBytes: [0xda])
        case _ where count <= 0xff_ff_ff_ff:
            try! packUInt(count, bytesReceivingPackage: &bytesReceivingPackage, overridingHeaderBytes: [0xdb])
        default:
            throw BytePressError.ArrayOutOfBounds(Int(count), 0)
        }
        bytesReceivingPackage += string.utf8
        
    }
}