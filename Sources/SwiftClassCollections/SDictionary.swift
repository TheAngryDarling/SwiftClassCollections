//
//  SDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-30.
//
// Protocol definitions to define any dictionary or mutable dictionary

import Foundation


/*
 Protocol defining a Swift Dictionary.  This is basicaly a Collection with a new name for standardization, adding methods and properties specific to Dictionaries
 */
public protocol SDictionary: Collection where Element == (key: Key, value: Value)  {
    
    associatedtype Key: Hashable
    associatedtype Value
    
    associatedtype Keys: Collection, Equatable where Keys.Element == Key, Keys.Index == Self.Index
    associatedtype Values : Collection where Values.Element == Value, Values.Index == Self.Index
    
    

    var keys: Keys { get }
    var values: Values { get }
    var first: Element? { get }
    
    subscript(key: Key) -> Value? { get }
    subscript(index: Index) -> Element { get }
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get }
    
    init()
    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
    init<S>(_ keysAndValues: S,
            uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value)
    
}

/*
 Protocol defining a Swift mutable Dictionary.  This is bascially an SDictionary with mutable properties and methods
 */
public protocol SMutableDictionary: SDictionary where Values: MutableCollection {
    
    var values: Values { get set }
    
    subscript(key: Key) -> Value? { get set }
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get set }
    
    mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
    mutating func removeValue(forKey key: Key) -> Value?
}



extension Dictionary: SMutableDictionary { }


public func ==<DictA, DictB>(lhs: DictA, rhs: DictB) -> Bool where DictA: SDictionary, DictB: SDictionary, DictA.Key == DictB.Key, DictA.Value == DictB.Value, DictA.Value: Equatable {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in lhs {
        guard let rhsv = rhs[k] else { return false }
        if v != rhsv { return false }
    }
    return true
}
