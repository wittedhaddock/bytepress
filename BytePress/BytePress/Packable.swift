//
//  Packable.swift
//  BytePress
//
//  Created by James William Graham on 12/19/15.
//  Copyright © 2015 caffeine. All rights reserved.
//


public protocol Packable {
    func pack() throws -> [UInt8]
}

extension Int : Packable {
    public func pack() throws -> [UInt8] {
        if self < Int(Int.max) && self > Int(Int.min) {
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
        throw BytePressError.UnsupportedType(self)
    }
}

extension Array where Element: Packable{
    func pack() -> [UInt8] {
        if self.count < 15 { /* */}
        var byteArray: [UInt8] = []
        for elem in self {
            byteArray += try! elem.pack()
        }
        return byteArray//todo: msgpack
    }
}

