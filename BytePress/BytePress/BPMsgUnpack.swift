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
        case 0xcd...0xcf:
            type = BytePressType.BPInteger(numericCast(try! unpackInt(data.dropFirst())))
        case 0xd0...0xd3:
            type = BytePressType.BPInteger(-1 * numericCast(try! unpackInt(data.dropFirst())))
        case 0xca:
            type = BytePressType.BPFloat(unsafeBitCast(try! unpackInt(data.dropFirst()), Float.self))
        case 0xcb:
            type = BytePressType.BPDouble(unsafeBitCast(try! unpackInt(data.dropFirst()), Double.self))
        case 0b10100000...0b10111111:
            type = BytePressType.BPString(try! unpackString(data.dropFirst(), withLength: UInt(header - 0b10100000)))
            
        default:
            throw BytePressError.BadMagic(data)
        }
        return type!
    }
    
    private class func unpackInt<T: SequenceType>(value : T) throws -> UInt64 {
        var extracted : UInt64 = 0 // how to match type to param, length, concisely?
        for octet in value {
            if let casted = octet as? UInt8 {
                extracted = extracted << 8 | numericCast(casted)
            }
            else {
                throw BytePressError.UnsupportedType(octet)
            }
        }
        return extracted
    }
    
    private class func unpackString<T: SequenceType>(value : T, withLength length: UInt) throws -> String {
        var arr: [UInt8] = Array<UInt8>()
        for i in value {
            arr.append(i as! UInt8) // needs to be changed to a cast
        }
        var decoder = UTF8()
        var generator = arr.generate()
        var str = ""
        for _ in 0..<length {
                switch decoder.decode(&generator) {
                case .Result(let res):
                    str.append(res)
                case .EmptyInput:
                    print("\(generator) returned empty after decoding attempt!" )
                case .Error:
                    print("\(generator) decoding caused error")
            }
        }
    return str
    }
}
