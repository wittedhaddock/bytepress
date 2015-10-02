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
        case _ where item is Int:
            
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
    
    private class func packInt(value: Int, inout bytesReceivingPackage: [UInt8]) throws {

        switch value{
        case -32..<0, 0...127:
            bytesReceivingPackage = [UInt8(value)]
            break
        case Int(Int8.min)...Int(Int8.max):
            bytesReceivingPackage = [0xd0, UInt8(value)]
            break
        case Int(Int16.min)...Int(Int16.max):
            bytesReceivingPackage = [0xd1] + unsafeBitCast(value, [UInt8].self)
            break
        case Int(Int32.min)...Int(Int32.max):
            break
        default:
            break
        }

    }
    
    private class func packString(string: String, inout bytesReceivingPackage: [UInt8]) throws  {
        guard false else {
            throw BytePressError.BadMagic(0xC)
        }
        
    }
}