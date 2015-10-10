//
//  BPMsgUnpack.swift
//  BytePress
//
//  Created by James William Graham on 10/7/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import Swift

extension CollectionType where Generator.Element == UInt8{}

public class BPMsgUnpack {
    public class func unpack<T: CollectionType>(data: T, breadcrumb: String) throws -> BytePressType {
        //assuming integer
        let type: BytePressType
        let header: UInt8 = data.first as! UInt8
        switch header {
        case 0...0x7f:
            type = BytePressType.BPInteger(Int(header))
        case 0xd0:
            type = try! unpackUInt(data, length: 1)!
        default:
            throw BytePressError.BadMagic(data)
            type = BytePressType.BPInteger(0)
            break
        }
        return type
    }
    
    private class func unpackUInt<T: CollectionType>(value : T, length: Int) throws -> BytePressType? {
        return BytePressType.BPInteger(0)
    }
}

