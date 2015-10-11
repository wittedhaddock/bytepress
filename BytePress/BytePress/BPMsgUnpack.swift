//
//  BPMsgUnpack.swift
//  BytePress
//
//  Created by James William Graham on 10/7/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import Swift

extension SequenceType where Generator.Element ==  UInt8{}
extension CollectionType where Generator.Element == UInt8{}

public class BPMsgUnpack {
    public class func unpack<T: CollectionType where T.Generator.Element == UInt8>(data: T, breadcrumb: String) throws -> BytePressType {
        //assuming integer
        let type: BytePressType?
        let header: UInt8 = data.first!
        switch header {
        case 0...0x7f:
            type = BytePressType.BPInteger(Int(header))
        case 0xcd:
            type = try? unpackUInt(data.dropFirst(), length: 1)!
        default:
            throw BytePressError.BadMagic(data)
        }
        return type!
    }
    
    private class func unpackUInt<T: SequenceType>(value : T, length: Int) throws -> BytePressType? {
        var extracted : UInt64 = 0 // how to match type to param, length, concisely?
        for octet in value {
            if let casted = octet as? UInt8 {
                extracted = extracted << 8 | numericCast(casted)
            }
            else {
                throw BytePressError.UnsupportedType(octet)
            }
        }
        return BytePressType.BPInteger(Int(extracted))
    }
}

