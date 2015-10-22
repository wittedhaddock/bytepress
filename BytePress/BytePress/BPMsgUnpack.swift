//
//  BPMsgUnpack.swift
//  BytePress
//
//  Created by James William Graham on 10/7/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import Swift

extension SequenceType where Generator.Element ==  UInt8{}
extension CollectionType {

}

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
            
            //TODO: conflate each three part into a single case generalizing each of the 3 (8, 16, 32)
        case 0xd9:
            let numNonUTFParts = 2
            let num = data.prefix(numNonUTFParts)
            //the second byte can just be cast to a UInt8 ... no need to call unpackInt in following expression, in other words
            type = BytePressType.BPString(try! unpackString(data.dropFirst(numNonUTFParts), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
        case 0xda:
            let numNonUTFParts = 3
            let num = data.prefix(numNonUTFParts)
            type = BytePressType.BPString(try! unpackString(data.dropFirst(numNonUTFParts), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
            
        case 0xdb:
            let numNonUTFParts = 5
            let num = data.prefix(numNonUTFParts)
            type = BytePressType.BPString(try! unpackString(data.dropFirst(numNonUTFParts), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
        case 0xc4:
            let prefix = 2
            let num = data.prefix(prefix)
            type = BytePressType.BPData(try! unpackBin(data.dropFirst(prefix), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
            
        case 0xc5:
            let prefix = 3
            let num = data.prefix(prefix)
            type = BytePressType.BPData(try! unpackBin(data.dropFirst(prefix), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
        case 0xc6:
            let prefix = 5
            let num = data.prefix(prefix)
            type = BytePressType.BPData(try! unpackBin(data.dropFirst(prefix), withLength: UInt(try! unpackInt(num, ignoreFirstByte: true))))
        default:
            throw BytePressError.BadMagic(data)
        }
        return type!
    }
    
    private class func unpackInt<T: SequenceType>(value : T, var ignoreFirstByte: Bool = false) throws -> UInt64 {
        var extracted : UInt64 = 0 // how to match type to param, length, concisely?
        for octet in value {
            if ignoreFirstByte {
                ignoreFirstByte = false // CODE SMELL ---> prefix.dropfirst call reutrns T.SequenceType.SequenceType and I haven't figured out this idea of recursive type support .. is a sequence of a sequence not still a sequence?
                continue
            }
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
            arr.append(i as! UInt8) // needs to be changed to a cast rather than whole new var
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
                    throw BytePressError.BadMagic("INPUT IS EMPTY")
                case .Error:
                    print("\(generator) decoding caused error")
            }
        }
    return str
    }
    
    private class func unpackBin<T: SequenceType>(value: T, withLength length: UInt) throws -> [UInt8] {
        var gen = value.generate()
        var octetArr = [UInt8]()
        for _ in 0..<length {
            if let octet = gen.next() {
                if let octetCasted = octet as? UInt8 {
                    octetArr.append(octetCasted)
                }
                else {
                    throw BytePressError.UnsupportedType(octet)
                }
            }
            else {
                throw BytePressError.BadLength(Int(length), 0)
            }
        }
        return octetArr
    }
}
