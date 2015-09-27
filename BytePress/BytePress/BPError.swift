//
//  BPError.swift
//  BytePress
//
//  Created by James William Graham on 9/27/15.
//  Copyright © 2015 caffeine. All rights reserved.
//

enum BytePressError : ErrorType{
    case BadMagic(UInt8) //The byte array uses an unknown msgpack type
    
    case BadLength(Int, Int) //A msgpack datastructure purports to be X bytes long, but only Y bytes exist
    //alternatively, you're trying to pack something that cannot be stored in MsgPack due to exceeding a length requirement
    
    case UnsupportedType(Any) //The Swift type is not supported (e.g., you asked us to pack an NSObject)
    
    case CantCast(Any, Any) //Operation implies casting A to B, but this is impossible
    
    case NotArray(Any) //convenience array functions are not supported on type
    
    case NotDictionary(Any) //convenience dictionary functions are not supported on type
    
    case KeyNotFound(String) //the specified key cannot be found
    
    case ArrayOutOfBounds(Int, Int) //Using an array convenience function beyond the bounds of the array
    
}