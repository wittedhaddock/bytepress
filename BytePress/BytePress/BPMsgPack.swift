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
            do {
                try packString(item as! String, bytesReceivingPackage: &bytes)
            }
            break
        case _ where item is Bool:
            try packBool(item as! Bool, bytesReceivingPackage: &bytes)
            break
        case _ where item is UInt:
            try packUInt(item as! UInt, bytesReceivingPackage: &bytes)
            break
        case _ where item is Int:
            try packInt(item as! Int, bytesReceivingPackage: &bytes)
            break
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
    
    private class func packUInt(value: UInt, inout bytesReceivingPackage: [UInt8]) throws {
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
            break
        case 0...UInt(UInt32.max):
            headerByte = 0xce
            strideLength = 32 - 8
            break
        case 0..<UInt(UInt64.max):
            headerByte = 0xcf
            strideLength = 64 - 8
            break
            
        default:
            headerByte = 0xc0
            strideLength = 0
            break;
        }
        
        bytesReceivingPackage = [headerByte] + strideLength.stride(through: 0, by: -8).map({ i in
            return UInt8(truncatingBitPattern: value >> i)
        })
    }
    private class func packInt(value: Int, inout bytesReceivingPackage: [UInt8]) throws {
        print("max: \(Int8.max), min: \(Int8.min)")
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
            break
        case Int(Int32.min)...Int(Int32.max):
            headerByte = value < 0 ? 0xd2 : 0xce
            strideLength = 16
            break
        case Int(Int64.min)...Int(Int64.max):
            headerByte = value < 0 ? 0xd3 : 0xcf
            strideLength = 32
            break
        default:
            strideLength = 0
            headerByte = 0xc0
            break
        }
        
        bytesReceivingPackage = [headerByte] + strideLength.stride(through: 0, by: -8).map({ i in
            return UInt8(truncatingBitPattern: value >> i)
        })

    }
    
    private class func packString(string: String, inout bytesReceivingPackage: [UInt8]) throws  {
        guard false else {
            throw BytePressError.BadMagic(0xC)
        }
        
    }
}