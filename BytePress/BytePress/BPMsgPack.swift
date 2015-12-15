//
//  BPMsgPack.swift
//  BytePress
//
//  Created by James William Graham on 9/12/15.
//  Copyright (c) 2015 caffeine. All rights reserved.
//


protocol ArrayType {}
extension Array: ArrayType {} //used to check for bin/arr... better way to do this type check? (let x = as? [Any] --> doesn't work)

public class BPMsgPack {
    public class func pack<T: Any>(item: T) throws -> [UInt8] {
        var appendage = [UInt8]()
        return try pack(item, appendedToBytes: &appendage)
    }
    public class func pack(item: Any, inout appendedToBytes bytesAppendage: [UInt8]) throws -> [UInt8] {
        switch item {
        case _ where item is String:
            try packString(item as! String, bytesReceivingPackage: &bytesAppendage)
        case _ where item is Bool:
            if item is Int {
                fallthrough // poor -- should be written differently .. an int is a bool
            }
            try packBool(item as! Bool, bytesReceivingPackage: &bytesAppendage)
        case _ where item is UInt:
            try packUInt(item as! UInt, bytesReceivingPackage: &bytesAppendage)
        case _ where item is Int:
            
            if let x = item as? Int {
                if x > 0 {
                    try packUInt(UInt(x), bytesReceivingPackage: &bytesAppendage)
                }
                else {
                    try packInt(item as! Int, bytesReceivingPackage: &bytesAppendage)
                }
            }
            else {
                throw BytePressError.BadMagic("something bizarre")
            }
            
        case _ where item is Float:
            try packUInt(UInt(unsafeBitCast(item as! Float, UInt32.self)), bytesReceivingPackage: &bytesAppendage, overridingHeaderBytes: [0xca])
        case _ where item is Double:
            try packUInt(UInt(unsafeBitCast(item as! Double, UInt64.self)), bytesReceivingPackage: &bytesAppendage, overridingHeaderBytes: [0xcb])
        case _ where item is ArrayType:
            if let binArr = item as? [UInt8] {
                try packBin(binArr, bytesReceivingPackage: &bytesAppendage)
                break
            }
            fallthrough
            
        case _ where item is Array<Any>:
            try packArray(item as! Array<Any>, bytesReceivingPackage: &bytesAppendage)
        default:
            throw BytePressError.BadMagic(item)
        }
        return bytesAppendage
    }
    
    private class func packBool(value: Bool, inout bytesReceivingPackage: [UInt8]) throws {

        bytesReceivingPackage.append(value ? 0xc3 : 0xc2)
    }
    
    private class func packUInt(value: UInt, inout bytesReceivingPackage: [UInt8], overridingHeaderBytes:[UInt8] = [0xc0]) throws {
        let headerByte: UInt8
        let strideLength: UInt
        switch value {
        case 0...UInt(UInt8.max)/2:
            bytesReceivingPackage += overridingHeaderBytes == [0xc0] ? [UInt8(value)] : overridingHeaderBytes + [UInt8(value)]
            return
        case 0...UInt(UInt8.max):
            bytesReceivingPackage += overridingHeaderBytes == [0xc0] ? [0xcc, UInt8(value)] : overridingHeaderBytes + [UInt8(value)]
            return
        case 0...UInt(UInt16.max):
            headerByte = 0xcd
            strideLength = 8
        case 0...UInt(UInt32.max):
            headerByte = 0xce
            strideLength = 32 - 8
        case 0..<UInt(UInt64.max):
            headerByte = 0xcf
            strideLength = 64 - 8
        default:
            throw BytePressError.BadLength(Int(UInt8.max), 0)
        }
        
        bytesReceivingPackage += (overridingHeaderBytes == [0xc0] ? [headerByte] : overridingHeaderBytes) + strideLength.stride(through: 0, by: -8).map({ i in
           
            return UInt8(truncatingBitPattern: value >> i)
        })
    }
    
    private class func packInt(value: Int, inout bytesReceivingPackage: [UInt8]) throws {
        let headerByte: UInt8
        let strideLength: Int
        switch value{
        case -32..<0, 0...127:
            //fix ints
            bytesReceivingPackage += [UInt8(value)]
            return
        case Int(Int8.min)...Int(Int8.max):
            //single byte of data
            bytesReceivingPackage += [value < 0 ? 0xd0 : 0xcc, UInt8(value)]
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
            throw BytePressError.ArrayOutOfBounds(value, 0)
        }
        bytesReceivingPackage += [headerByte] + strideLength.stride(through: 0, by: -8).map({ i in
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
            bytesReceivingPackage += headerBytes + string.utf8
            return
        case _ where count <= 0xff:
            headerBytes = [0xd9]
            bytesReceivingPackage += headerBytes + [UInt8(count)] + string.utf8
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
    
    private class func packBin(value: [UInt8], inout bytesReceivingPackage: [UInt8]) throws {
        let len = UInt(value.count) // theoretically (msgpack spec disallows) , what if count is UInt32.max + 1 and greater?
        var numBin: [UInt8] = [UInt8]() // do without initialization
        switch len {
        case 0...UInt(UInt8.max):
            try packUInt(len, bytesReceivingPackage: &numBin, overridingHeaderBytes: [0xc4])
        case 0...UInt(UInt16.max):
            try packUInt(len, bytesReceivingPackage: &numBin, overridingHeaderBytes: [0xc5])
        case 0...UInt(UInt32.max):
            try packUInt(len, bytesReceivingPackage: &numBin, overridingHeaderBytes: [0xc6])
        default:
            throw BytePressError.UnsupportedType(value)
        }
        bytesReceivingPackage += numBin + value
    }
    
    private class func packArray(value: Array<Any>, inout bytesReceivingPackage: [UInt8]) throws {
        let len = UInt(value.count)
        let header: [UInt8]
        switch len {
        case 0..<0b10010000:
            header = [0b10010000 | UInt8(len)]
        case 0...UInt(UInt16.max):
            header = [0xdc]
        case 0...UInt(UInt32.max):
            header = [0xdd]
        default:
            throw BytePressError.BadLength(Int(len), 0)
        }
        bytesReceivingPackage = header + bytesReceivingPackage
        for subValue in value {
                try! pack(subValue, appendedToBytes: &bytesReceivingPackage)
        }
    }
}