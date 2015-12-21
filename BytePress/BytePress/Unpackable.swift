//
//  Unpackable.swift
//  BytePress
//
//  Created by James William Graham on 12/19/15.
//  Copyright © 2015 caffeine. All rights reserved.
//


//proposal 1
func unpack() ->  Any {
    return 0
}

protocol Unpackable {
    static func unpack(arr: [UInt8]) throws -> Self //Int.unpack([2,3,4,5])
}

//proposal 2


/*enum BytePressUnpackable {
    case Int
    case String
    
    var myType: BytePressType {
        get {
            switch(self) {
            case .Int:
                return BytePressType.BPInteger
            default:
                abort()
            }
        }
    }
    
    var int : Int? { abort() }
    var string: String? { abort() }
}*/

//func unpack() -> BytePressType { abort()}
