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

extension Bool : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        return [self ? 0xc3 : 0xc2]
    }
}

extension UInt : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xcf]) throws -> [UInt8] {
        if self > UInt(Int64.max) && self <= UInt(UInt64.max) { //not sure
            return overridingHeaderBytes + (64 - 8).stride(through: 0, by: -8).map({ i in
                return UInt8(truncatingBitPattern: self >> i) // should be encapsulated elsewhere to DRY
            })
        }
        else {
            return try! Int(self).pack(overridingHeaderBytes)
        }
    }
}

extension UInt8 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xcc]) throws -> [UInt8] {
        return self < 127 ? [self] : (overridingHeaderBytes + [self])
    }
}

extension UInt16 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xcd]) throws -> [UInt8] {
        return try! UInt(self).pack(overridingHeaderBytes)
    }
}

extension UInt32 : Packable { //same as UInt extension... better solution?
    public func pack(overridingHeaderBytes: [UInt8] = [0xce]) throws -> [UInt8] { // header byte?
        return try! UInt(self).pack(overridingHeaderBytes)
    }
}

extension UInt64 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xcf]) throws -> [UInt8] { // header byte?
        return try! UInt(self).pack(overridingHeaderBytes) // if self is bigger than UInt32...
    }
}

extension Int : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        if self > Int(Int.min) && self < 0 {
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

extension Int8 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xd0]) throws -> [UInt8] {
        return try! unsafeBitCast(self, UInt8.self).pack(overridingHeaderBytes)
    }
}

extension Int16 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xd1]) throws -> [UInt8] {
        return try! unsafeBitCast(self, UInt16.self).pack(overridingHeaderBytes)
    }
}

extension Int32 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xd2]) throws -> [UInt8] {
        return try! unsafeBitCast(self, UInt32.self).pack(overridingHeaderBytes)
    }
}

extension Int64 : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xd3]) throws -> [UInt8] {
        return try! unsafeBitCast(self, UInt64.self).pack(overridingHeaderBytes)
    }
}

extension Float : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xca]) throws -> [UInt8] {
        let a = unsafeBitCast(self, UInt32.self)
        return try! a.pack(overridingHeaderBytes)
    }
}

/*extension Float32 : Packable {
    public func pack(overridingHeaderbytes: [UInt8] = [0xca]) throws -> [UInt8] {
        return try! Float(self).pack()

    }
} same as Float */

extension Double : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xcb]) throws -> [UInt8] {
        let a = unsafeBitCast(self, UInt64.self)
        return try! a.pack(overridingHeaderBytes)
    }
}
extension String : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        //TODO error handling for counts bigger than 255
        var bytesReceivingPackage = [UInt8]()
        let headerBytes: [UInt8]
        let count = UInt(self.utf8.count)
        switch count {
        case _ where count <= 0x1f:
            headerBytes = [0b10100000 | UInt8(count)]
            return headerBytes + self.utf8
        case _ where count <= 0xff:
            headerBytes = [0xd9]
            return headerBytes + [UInt8(count)] + self.utf8
        case _ where count <= 0xff_ff:
            bytesReceivingPackage += try! count.pack([0xda])
        case _ where count <= 0xff_ff_ff_ff:
            bytesReceivingPackage += try! count.pack([0xdb])
        default:
            throw BytePressError.ArrayOutOfBounds(Int(count), 0)
        }
        return bytesReceivingPackage + self.utf8
    }
}

extension CollectionType where Generator.Element == UInt8 {
    
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        var bytesReceivingPackage = [UInt8]()
        let len = UInt(self.count.hashValue) // theoretically (msgpack spec disallows) , what if count is UInt32.max + 1 and greater?
        switch len {
        case 0...UInt(UInt8.max):
            bytesReceivingPackage += try! len.pack([0xc4])
        case 0...UInt(UInt16.max):
            bytesReceivingPackage += try! len.pack([0xc5])
        case 0...UInt(UInt32.max):
            bytesReceivingPackage += try! len.pack([0xc6])
        default:
            throw BytePressError.UnsupportedType(self)
        }
        return bytesReceivingPackage + self
    }
}




/*extension Array:Packable where Element: Packable{
    func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        let header: UInt8

        if self.count < 0b10010000 {
            header = UInt8(0b10010000 | self.count)
        }
        else if self.count <= Int(UInt16.max) {
            header = 0xdc
        }
        else if self.count <= Int(UInt32.max) {
            header = 0xdd
        }
        else {
            throw BytePressError.BadLength(0, self.count)
        }
        
        var byteArray: [UInt8] = []
        for elem in self {
            byteArray += try! elem.pack([0xc0])
        }
        return [header] + byteArray//todo: msgpack
    }
}
waiting for swift 3
*/
extension Array : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        let header: UInt8
        
        if self.count < 0b10010000 {
            header = UInt8(0b10010000 | self.count)
        }
        else if self.count <= Int(UInt16.max) {
            header = 0xdc
        }
        else if self.count <= Int(UInt32.max) {
            header = 0xdd
        }
        else {
            throw BytePressError.BadLength(0, self.count)
        }
        
        var byteArray: [UInt8] = []
        for elem in self {
            if elem is Packable {
                byteArray += try! (elem as! Packable).pack([0xc0])
            }
        }
        return [header] + byteArray//todo: msgpack
    }
}

extension Dictionary : Packable {
    public func pack(overridingHeaderBytes: [UInt8] = [0xc0]) throws -> [UInt8] {
        let header : [UInt8]
        if self.count < 16 {
            header = [UInt8(0b10000000 | self.count)]
        }
        else if self.count <= Int(UInt16.max) {
            header = try! UInt16(self.count).pack([0xde])
        }
        else if self.count <= Int(UInt32.max) {
            header = try! UInt32(self.count).pack([0xdf])
        }
        else {
            throw BytePressError.BadLength(0, self.count)
        }
        var byteArray: [UInt8] = []
        for keyvalue in self {
            if keyvalue.0 is Packable && keyvalue.1 is Packable{
                byteArray += try! (keyvalue.0 as! Packable).pack([0xc0]) + (try! (keyvalue.1 as! Packable).pack([0xc0]))
            }
            else {
                throw BytePressError.UnsupportedType(self)
            }
        }
        return header + byteArray
    }
}

