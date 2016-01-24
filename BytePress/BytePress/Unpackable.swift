//
//  Unpackable.swift
//  BytePress
//
//  Created by James William Graham on 12/19/15.
//  Copyright © 2015 caffeine. All rights reserved.
//





enum BytePressUnpackable {
    case Int
    case String
    
    var myType: BytePressType {
        get {
            switch(self) {
            case .Int:
                return BytePressType.BPInteger(0)
            default:
                return BytePressType.BPInteger(0)
            }
        }
    }
    
   
}
//func unpack() -> BytePressType { abort()}
