//
//  BPMsgUnpack.swift
//  BytePress
//
//  Created by James William Graham on 10/7/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import Swift

protocol BytePressByteArray: CollectionType {
    subscript(subRange: Range<Int>) -> ArraySlice<Self.Generator.Element> { get }
    subscript(index: Int) -> Self.Generator.Element { get }
    //blah blah more functional requirements here
}
extension Array: BytePressByteArray{}



public class BPMsgUnpack {
    public class func valueFromBytePressType(type: BytePressType) -> AnyObject {
        switch type{
        case .BPInteger(let a):
            return a
        case .BPString(let a):
            return a
        case .BPFloat(let a):
            return a
        case .BPDouble(let a):
            return a
        case .BPData(let a):
            return a as! AnyObject
        case .BPArray(let a):
            return a as AnyObject
        default:
            return 0
        }
    }
    public class func unpack<T: CollectionType where T.SubSequence: CollectionType, T.SubSequence.Generator.Element == T.Generator.Element, T.SubSequence.SubSequence == T.SubSequence, T.Generator.Element == UInt8>
(data: T, breadcrumb: String) throws -> BytePressType {
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
        case 0xcc:
            type = BytePressType.BPInteger(numericCast(try! unpackInt(data.dropFirst())))
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
        case 0b10010000...0b10011111:
            let k = Array(data.dropFirst())
            type = BytePressType.BPArray(try! unpackArray(k, withLength: UInt(header) - 0b1001000))
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
    
    private class func unpackArray<T: BytePressByteArray where T.Generator.Element == UInt8>(value: T, withLength length: UInt) throws -> [AnyObject] {
        var b: Array<AnyObject> = [AnyObject]()
        var range = Range(start: 0, end: correspondingLengthToByte(value.first!))
        

        //below implementation seems kluge to me... there's probably a more elegant functional alternative
        for _ in 0..<value.count.hashValue {
            print("value: \(value) range: \(range)")
            let c = valueFromBytePressType(try! unpack(value[range], breadcrumb: ""))
            b.append(c)
            range.startIndex = range.endIndex
            if range.startIndex < value.count.hashValue {
                range.endIndex = range.startIndex + correspondingLengthToByte(value[range.startIndex])
            }
            else {
                break
            }
        }
        return b
    }
    
    private class func correspondingLengthToByte(byte: UInt8) -> Int {
        //includes header: i.e. bool is 1, nil is 1, uint8 is 2
        switch byte {
        case 0x00...0xc3:
            return 1
        case 0xcc, 0xd0:
            return 2
        case 0xcd, 0xd1:
            return 3
        case 0xce, 0xca:
            return 5
        case 0xcb, 0xd3:
            return 9
        default:
            return 0
        
        }
    }
}
