//
//  BytePressType.swift
//  BytePress
//
//  Created by James William Graham on 9/18/15.
//  Copyright (c) 2015 caffeine. All rights reserved.
//
typealias Ext = (ext: Int, data: CollectionType)
enum BytePressType {
    case BPInteger(Int)
    case BPString(String)
    case BPFloat(Float)
    case BPDouble(Double)
    case BPData(CollectionType)
}