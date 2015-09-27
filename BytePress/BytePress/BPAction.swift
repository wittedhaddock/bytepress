//
//  BPAction.swift
//  BytePress
//
//  Created by James William Graham on 9/27/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

public class BPAction {
    public class func pack(item: Any) throws -> [UInt8] {
        var bytes: [UInt8] = Array<UInt8>()
        
        switch item {
            case _ where item is String:
                packString(item as! String, bytesReceivingPackage: &bytes)
        default:
            print("illegit")
            
        }
        
        return bytes
        
    }
    
    private class func packString(string: String, inout bytesReceivingPackage: [UInt8]) {
        bytesReceivingPackage.append(0x3)
    }
}