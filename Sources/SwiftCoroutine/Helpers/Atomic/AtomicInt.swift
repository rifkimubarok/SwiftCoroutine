//
//  AtomicInt.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 01.04.2020.
//  Copyright © 2020 Alex Belozierov. All rights reserved.
//

#if SWIFT_PACKAGE
import CCoroutine
#endif

internal struct AtomicInt {
    
    private var _value: Int
    
    @inlinable init(value: Int = 0) {
        _value = value
    }
    
    @inlinable var value: Int {
        get { _value }
        set {
            withUnsafeMutablePointer(to: &_value) {
                __atomicStore(OpaquePointer($0), newValue)
            }
        }
    }
    
    @discardableResult @inlinable
    mutating func add(_ value: Int) -> Int {
        withUnsafeMutablePointer(to: &_value) {
            __atomicFetchAdd(OpaquePointer($0), value)
        }
    }
    
    @discardableResult @inlinable
    mutating func update(_ transform: (Int) -> Int) -> (old: Int, new: Int) {
        withUnsafeMutablePointer(to: &_value) {
            var oldValue = $0.pointee, newValue: Int
            repeat { newValue = transform(oldValue) }
                while __atomicCompareExchange(OpaquePointer($0), &oldValue, newValue) == 0
            return (oldValue, newValue)
        }
    }
    
    @inlinable mutating func update(_ newValue: Int) -> Int {
        withUnsafeMutablePointer(to: &_value) {
            __atomicExchange(OpaquePointer($0), newValue)
        }
    }
    
}
