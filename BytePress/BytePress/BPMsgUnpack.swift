//
//  BPMsgUnpack.swift
//  BytePress
//
//  Created by James William Graham on 10/7/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

import Swift
public class BPMsgUnpack {
    public class func pack<T: CollectionType where T._Element == UInt8>(data: T, breadcrumb: String) throws -> BytePressType {
        //assuming integer
        let header: UInt8 = data.first as! UInt8
        switch header {
        case 0...0x7f:
            return BytePressType.BPInteger(Int(header))
        case 0xd0: break
        }
    }
}