//
//  SCDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-23.
//

import Foundation

/*
 A class that provides the same functionality as a regular swift Dictionary
 This privides a typed based replacement for NSDictionary and NSMutableDictionary
*/
public final class SCDictionary<Key, Value> where Key: Hashable {
    
    public typealias Keys = Dictionary<Key, Value>.Keys
    public typealias Values = Dictionary<Key, Value>.Values
    
    fileprivate var storage: Dictionary<Key, Value>
    
    
    public var keys: Keys { return self.storage.keys }
    public var values: Values {
        get { return self.storage.values }
        set { self.storage.values = newValue }
    }
    
    
    fileprivate init(_ dictionary: Dictionary<Key, Value>) { self.storage = dictionary }
    
    public init() { self.storage = Dictionary<Key, Value>() }
    
    public init(minimumCapacity: Int) {
        self.storage = Dictionary<Key, Value>(minimumCapacity: minimumCapacity)
    }
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.storage = Dictionary<Key, Value>(uniqueKeysWithValues: keysAndValues)
    }
    
    public init<S>(_ keysAndValues: S,
                   uniquingKeysWith combine: (Dictionary<Key, Value>.Value, Dictionary<Key, Value>.Value) throws -> Dictionary<Key, Value>.Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.storage = try Dictionary<Key, Value>(keysAndValues, uniquingKeysWith: combine)
    }
    
    public init<S>(grouping values: S,
                   by keyForValue: (S.Element) throws -> Dictionary<Key, Value>.Key) rethrows where Value == [S.Element], S : Sequence {
        self.storage = try Dictionary<Key, Value>(grouping: values, by: keyForValue)
    }
    
    public subscript(key: Key) -> Value? {
        get { return self.storage[key] }
        set { self.storage[key] = newValue }
    }
    
    public subscript(key: Key,
        default defaultValue: @autoclosure () -> Value) -> Value {
        get { return self.storage[key] ?? defaultValue()  }
        set { self.storage[key] = newValue }
    }
    
    
    
    public func index(forKey key: Key) -> Index? {
        return self.storage.index(forKey: key)
    }
    
    @discardableResult
    public func updateValue(_ value: Value, forKey key: Key) -> Value? {
        return self.storage.updateValue(value, forKey: key)
    }
    
    public func merge(_ other: SCDictionary<Key, Value>,
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try self.storage.merge(other.storage, uniquingKeysWith: combine)
    }
    
    public func merge(_ other: [Key : Value],
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try self.storage.merge(other, uniquingKeysWith: combine)
    }
    
    public func merge<D>(_ other: D,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where D: SDictionary, D.Key == Key, D.Value == Value {
        for (k,v) in other {
            if let oldV = self.storage[k] {
                self.storage[k] = try combine(oldV, v)
            } else {
                self.storage[k] = v
            }
        }
    }
    
    public func merge<S>(_ other: S,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        try self.storage.merge(other, uniquingKeysWith: combine)
    }
    
    public func merging(_ other: SCDictionary<Key, Value>,
                        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCDictionary<Key, Value> {
        return SCDictionary<Key, Value>(try self.storage.merging(other.storage, uniquingKeysWith: combine))
    }
    
    public func merging<S>(_ other: S,
                           uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCDictionary<Key, Value>  where S : Sequence, S.Element == (Key, Value) {
        return SCDictionary<Key, Value>(try self.storage.merging(other, uniquingKeysWith: combine))
    }
    
    public func reserveCapacity(_ minimumCapacity: Int) { return self.storage.reserveCapacity(minimumCapacity) }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SCDictionary<Key, Value> {
        return SCDictionary<Key, Value>(try self.storage.filter(isIncluded))
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Key : Value] {
        return try self.storage.filter(isIncluded)
    }
    
    public func removeValue(forKey key: Key) -> Value? { return self.storage.removeValue(forKey: key) }
    public func removeAll(keepingCapacity keepCapacity: Bool = false) { self.storage.removeAll(keepingCapacity: keepCapacity) }
    
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key : T] {
        return try self.storage.mapValues(transform)
    }
    
    public func popFirst() -> (key: Key, value: Value)? {
        return self.storage.popFirst()
    }
    
    
    
}

// MARK: - Conformance

// MARK: - Conformance -- Collection
extension SCDictionary: Collection {
    
    public typealias Element = Dictionary<Key, Value>.Element
    public typealias Index = Dictionary<Key, Value>.Index
    public typealias Indices = Dictionary<Key, Value>.Indices
    
    // A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool { return self.storage.isEmpty }
    // The number of elements in the array.
    public var count: Int { return self.storage.count }
    // The total number of elements that the array can contain without allocating new storage.
    public var capacity: Int { return self.storage.capacity }
    
    // The position of the first element in a nonempty array.
    public var startIndex: Index { return self.storage.startIndex }
    // The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index { return self.storage.endIndex }
    // The indices that are valid for subscripting the collection, in ascending order.
    public var indices: Indices { return self.storage.indices }
    
    // Accesses the element at the specified position.
    public subscript(position: Index) -> Element { return self.storage[position] }
    
    // Returns an iterator over the elements of the collection.
    public func makeIterator() -> DictionaryIterator<Key, Value> { return self.storage.makeIterator() }
    // Returns the position immediately after the given index.
    public func index(after i: Index) -> Index { return self.storage.index(after: i) }
    // Removes and returns the element at the specified position.
    public func remove(at index: Index) -> Element { return self.storage.remove(at: index) }
    
    /*public func split(maxSplits: Int = Int.max,
                      omittingEmptySubsequences: Bool = true,
                      whereSeparator isSeparator: ((key: Key, value: Value)) throws -> Bool) rethrows -> [Slice<Dictionary<Key, Value>>] {
        return try self.storage.split(maxSplits: maxSplits,
                                      omittingEmptySubsequences: omittingEmptySubsequences,
                                      whereSeparator: isSeparator)
    }
    
    public func prefix(through position: Index) -> Slice<Dictionary<Key, Value>> {
        return self.storage.prefix(through: position)
    }
    
    public func prefix(upTo end: Index) -> Slice<Dictionary<Key, Value>> {
        return self.storage.prefix(upTo: end)
    }
    
    public func prefix(while predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Slice<Dictionary<Key, Value>> {
        return try self.storage.prefix(while: predicate)
    }
    
    public func prefix(_ maxLength: Int) -> Slice<Dictionary<Key, Value>> {
        return self.storage.prefix(maxLength)
    }
    
    public func suffix(from start: Index) -> Slice<Dictionary<Key, Value>> {
        return self.storage.suffix(from: start)
    }
    
    public func suffix(_ maxLength: Int) -> Slice<Dictionary<Key, Value>> {
        return self.storage.suffix(maxLength)
    }
    
    public func drop(while predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Slice<Dictionary<Key, Value>> {
        return try self.storage.drop(while: predicate)
    }
    
    public func dropLast(_ k: Int) -> Slice<Dictionary<Key, Value>> {
        return self.storage.dropLast(k)
    }
    
    public func dropFirst(_ k: Int) -> Slice<Dictionary<Key, Value>> {
        return self.storage.dropFirst(k)
    }*/
}

// MARK: - Conformance -- ExpressibleByDictionaryLiteral
extension SCDictionary: ExpressibleByDictionaryLiteral {
    public convenience init(dictionaryLiteral elements: (Key, Value)...) {
        var d: [Key: Value] = [:]
        for kv in elements {
            d[kv.0] = kv.1
        }
        self.init(d)
    }
}

// MARK: - Conformance -- CustomStringConvertible, CustomDebugStringConvertible
extension SCDictionary: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return self.storage.debugDescription }
    public var debugDescription: String { return self.storage.debugDescription }
}

// MARK: - Conformance -- CustomReflectable
extension SCDictionary: CustomReflectable {
    public var customMirror: Mirror { return self.storage.customMirror }
}

// MARK: - Conformance -- SMutableDictionary
extension SCDictionary: SMutableDictionary {
    public convenience init<D>(_ dictionary: D) where D: SDictionary, D.Key == Key, D.Value == Value {
        self.init()
        self.reserveCapacity(dictionary.count)
        for (k,v) in dictionary {
            self[k] = v
        }
    }
}


// MARK: - Conditional conformance
#if swift(>=4.1)
// MARK: - Conformance -- Encodable
extension SCDictionary: Encodable where Key: Encodable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try self.storage.encode(to: encoder)
    }
}

// MARK: - Conformance -- Decodable
extension SCDictionary: Decodable where Key: Decodable, Value: Decodable {
    public convenience init(from decoder: Decoder) throws {
        let d = try Dictionary<Key, Value>(from: decoder)
        self.init(d)
    }
}


// MARK: - Conformance -- Equatable
extension SCDictionary: Equatable where Value: Equatable {
    public static func == (lhs: SCDictionary, rhs: SCDictionary) -> Bool {
        return lhs.storage == rhs.storage
    }
}

#if swift(>=4.2)
// MARK: - Conformance -- Hashable
extension SCDictionary: Hashable where Key: Hashable, Value: Hashable {
    public var hashValue: Int { return self.storage.hashValue }


    public func hash(into hasher: inout Hasher) {
        return self.storage.hash(into: &hasher)
    }
}
#endif

#endif


// MARK: - Base equatable operators
public func ==<Key,Value>(lhs: Dictionary<Key, Value>, rhs: SCDictionary<Key, Value>) -> Bool where Value: Equatable  {
    return lhs == rhs.storage
}
public func ==<Key,Value>(lhs: SCDictionary<Key, Value>, rhs: Dictionary<Key, Value>) -> Bool where Value: Equatable {
    return lhs.storage == rhs
}
