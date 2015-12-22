//
//  Packable.swift
//  BytePress
//
//  Created by James William Graham on 12/19/15.
//  Copyright © 2015 caffeine. All rights reserved.
//


public protocol Packable {
    func pack(overridingHeaderBytes: [UInt8]) throws -> [UInt8]
}

extension UInt : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        if self > UInt(Int64.max) && self <= UInt(UInt64.max) {
            return [0xcf] + (64 - 8).stride(through: 0, by: -8).map({ i in
                return UInt8(truncatingBitPattern: self >> i) // should be encapsulated elsewhere to DRY
            })
        }
        else {
            return try! Int(self).pack()
        }
    }
}

extension Int : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        if self > Int(Int.min) && self < 0{
            var bytesReceivingPackage = [UInt8]()
            let headerByte: UInt8
            let strideLength: Int
            switch self{
            case -32..<0, 0...127:
                //fix ints
                bytesReceivingPackage += [UInt8(self)]
                return bytesReceivingPackage
            case Int(Int8.min)...Int(Int8.max):
                //single byte of data
                bytesReceivingPackage += [self < 0 ? 0xd0 : 0xcc, UInt8(self)]
                return bytesReceivingPackage
            case Int(Int16.min)...Int(Int16.max):
                headerByte = self < 0 ? 0xd1 : 0xcd
                strideLength = 8
            case Int(Int32.min)...Int(Int32.max):
                headerByte = self < 0 ? 0xd2 : 0xce
                strideLength = 32 - 8
            case Int(Int64.min)..<Int(Int64.max):
                headerByte = self < 0 ? 0xd3 : 0xcf
                strideLength = 64 - 8
            default:
                throw BytePressError.ArrayOutOfBounds(self, 0)
            }
            bytesReceivingPackage += [headerByte] + strideLength.stride(through: 0, by: -8).map({ i in
                return UInt8(truncatingBitPattern: (-self >> i))
            })
            return bytesReceivingPackage
        }
        else if self < Int(Int.max){
            var bytesReceivingPackage = [UInt8]()
            let headerByte: UInt8
            let strideLength: UInt
            switch self {
            case 0...Int(Int8.max):
                bytesReceivingPackage += overridingHeaderBytes == [0xc0] ? [UInt8(self)] : overridingHeaderBytes + [UInt8(self)]
                return bytesReceivingPackage
            case 0...Int(UInt8.max):
                bytesReceivingPackage += overridingHeaderBytes == [0xc0] ? [0xcc, UInt8(self)] : overridingHeaderBytes + [UInt8(self)]
                return bytesReceivingPackage
            case 0...Int(UInt16.max):
                headerByte = 0xcd
                strideLength = 8
            case 0...Int(UInt32.max):
                headerByte = 0xce
                strideLength = 32 - 8
            case 0..<Int(Int64.max):
                headerByte = 0xcf
                strideLength = 64 - 8
            default:
                throw BytePressError.BadLength(Int(UInt8.max), 0)
            }
            
            bytesReceivingPackage += (overridingHeaderBytes == [0xc0] ? [headerByte] : overridingHeaderBytes) + strideLength.stride(through: 0, by: -8).map({ i in
                
                return UInt8(truncatingBitPattern: self >> Int(i))
            })
            return bytesReceivingPackage
        }
        throw BytePressError.UnsupportedType(self)
    }
}

extension Array where Element: Packable{
    func pack() -> [UInt8] {
        if self.count < 15 { /* */}
        var byteArray: [UInt8] = []
        for elem in self {
          //  byteArray += try! elem.pack()
        }
        return byteArray//todo: msgpack
    }
}

