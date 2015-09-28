//
//  BPMsgPack.swift
//  BytePress
//
//  Created by James William Graham on 9/12/15.
//  Copyright (c) 2015 caffeine. All rights reserved.
//



public class BPMsgPack {
    public class func pack(item: Any) throws -> [UInt8] {
        var bytes: [UInt8] = Array<UInt8>()
        
        switch item {
        case _ where item is String:
            do {
                try packString(item as! String, bytesReceivingPackage: &bytes)
                
            } catch BytePressError.BadMagic(0x0){
                print("bad mojo!")
            }

            break
        default:
            print("illegit")
            
        }
        
        return bytes
        
    }
    
    private class func packString(string: String, inout bytesReceivingPackage: [UInt8]) throws  {
        guard false else {
            throw BytePressError.BadMagic(0x0)
        }
        
    }
}