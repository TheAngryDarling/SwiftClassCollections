//
//  SCDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-23.
//

import Foundation


/// A class that provides the same functionality as a regular swift Dictionary
/// This privides a typed based replacement for NSDictionary and NSMutableDictionary
public final class SCDictionary<Key, Value> where Key: Hashable {
    
    /// A view of a dictionary’s keys.
    public typealias Keys = Dictionary<Key, Value>.Keys
    /// A view of a dictionary’s values.
    public typealias Values = Dictionary<Key, Value>.Values
    
    fileprivate var storage: Dictionary<Key, Value>
    
    
    /// A collection containing just the keys of the dictionary.
    public var keys: Keys { return self.storage.keys }
    /// A collection containing just the values of the dictionary.
    public var values: Values {
        get { return self.storage.values }
        set { self.storage.values = newValue }
    }
    
    
    fileprivate init(_ dictionary: Dictionary<Key, Value>) { self.storage = dictionary }
    
    /// Creates an empty dictionary.
    public init() { self.storage = Dictionary<Key, Value>() }
    /// Creates an empty dictionary with preallocated space for at least the specified number of elements.
    ///
    /// - Parameter minimumCapacity: The minimum number of key-value pairs that the newly created dictionary should be able to store without reallocating its storage buffer.
    public init(minimumCapacity: Int) {
        self.storage = Dictionary<Key, Value>(minimumCapacity: minimumCapacity)
    }
    /// Creates a new dictionary from the key-value pairs in the given sequence.
    ///
    /// - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary. Every key in keysAndValues must be unique.
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.storage = Dictionary<Key, Value>(uniqueKeysWithValues: keysAndValues)
    }
    /// Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameter:
    ///   - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
    public init<S>(_ keysAndValues: S,
                   uniquingKeysWith combine: (Dictionary<Key, Value>.Value, Dictionary<Key, Value>.Value) throws -> Dictionary<Key, Value>.Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.storage = try Dictionary<Key, Value>(keysAndValues, uniquingKeysWith: combine)
    }
    
    /// Creates a new dictionary whose keys are the groupings returned by the given closure and whose values are arrays of the elements that returned each key.
    ///
    /// - Parameter:
    ///   - values: A sequence of values to group into a dictionary.
    ///   - keyForValue: A closure that returns a key for each element in values.
    public init<S>(grouping values: S,
                   by keyForValue: (S.Element) throws -> Dictionary<Key, Value>.Key) rethrows where Value == [S.Element], S : Sequence {
        self.storage = try Dictionary<Key, Value>(grouping: values, by: keyForValue)
    }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// - Parameter:
    ///   - key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    public subscript(key: Key) -> Value? {
        get { return self.storage[key] }
        set { self.storage[key] = newValue }
    }
    
    /// Accesses the value with the given key. If the dictionary doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the dictionary.
    ///
    /// - Parameters:
    ///   - key: The key the look up in the dictionary.
    ///   - defaultValue: The default value to use if key doesn’t exist in the dictionary.
    /// - Returns: The value associated with key in the dictionary; otherwise,defaultValue`.
    public subscript(key: Key,
        default defaultValue: @autoclosure () -> Value) -> Value {
        get { return self.storage[key] ?? defaultValue()  }
        set { self.storage[key] = newValue }
    }
    
    /// Returns the index for the given key.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The index for key and its associated value if key is in the dictionary; otherwise, nil.
    public func index(forKey key: Key) -> Index? {
        return self.storage.index(forKey: key)
    }
    
    /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with value. If key already exists in the dictionary, value replaces the existing associated value. If key isn’t already a key of the dictionary, the (key, value) pair is added.
    /// - Returns: The value that was replaced, or nil if a new key-value pair was added.
    @discardableResult
    public func updateValue(_ value: Value, forKey key: Key) -> Value? {
        return self.storage.updateValue(value, forKey: key)
    }
    
    /// Merges the given dictionary into this dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    public func merge(_ other: SCDictionary<Key, Value>,
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try self.storage.merge(other.storage, uniquingKeysWith: combine)
    }
    
    /// Merges the given dictionary into this dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    public func merge(_ other: [Key : Value],
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        try self.storage.merge(other, uniquingKeysWith: combine)
    }
    
    /// Merges the key-value pairs in the given sequence into the dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A sequence of key-value pairs.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
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
    
    /// Merges the key-value pairs in the given sequence into the dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A sequence of key-value pairs.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    public func merge<S>(_ other: S,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        try self.storage.merge(other, uniquingKeysWith: combine)
    }
    
    /// Creates a dictionary by merging the given dictionary into this dictionary, using a combining closure to determine the value for duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    public func merging(_ other: SCDictionary<Key, Value>,
                        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCDictionary<Key, Value> {
        return SCDictionary<Key, Value>(try self.storage.merging(other.storage, uniquingKeysWith: combine))
    }
    
    /// Creates a dictionary by merging the given dictionary into this dictionary, using a combining closure to determine the value for duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    public func merging<S>(_ other: S,
                           uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCDictionary<Key, Value>  where S : Sequence, S.Element == (Key, Value) {
        return SCDictionary<Key, Value>(try self.storage.merging(other, uniquingKeysWith: combine))
    }
    
    /// Reserves enough space to store the specified number of key-value pairs.
    ///
    /// - Parameter minimumCapacity: The requested number of key-value pairs to store.
    public func reserveCapacity(_ minimumCapacity: Int) { return self.storage.reserveCapacity(minimumCapacity) }
    
    /// Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its argument and returns a Boolean value indicating whether the pair should be included in the returned dictionary.
    /// - Returns: A dictionary of the key-value pairs that isIncluded allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SCDictionary<Key, Value> {
        return SCDictionary<Key, Value>(try self.storage.filter(isIncluded))
    }
    
    /// Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its argument and returns a Boolean value indicating whether the pair should be included in the returned dictionary.
    /// - Returns: A dictionary of the key-value pairs that isIncluded allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Key : Value] {
        return try self.storage.filter(isIncluded)
    }
    
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or nil if the key was not present in the dictionary.
    @discardableResult public func removeValue(forKey key: Key) -> Value? { return self.storage.removeValue(forKey: key) }
    /// Removes all key-value pairs from the dictionary.
    ///
    /// - Parameter keepCapacity: Whether the dictionary should keep its underlying buffer. If you pass true, the operation preserves the buffer capacity that the collection has, otherwise the underlying buffer is released. The default is false.
    public func removeAll(keepingCapacity keepCapacity: Bool) { self.storage.removeAll(keepingCapacity: keepCapacity) }
    
    /// Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms a value. transform accepts each value of the dictionary as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the keys and transformed values of this dictionary.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key : T] {
        return try self.storage.mapValues(transform)
    }
    
    /// Removes and returns the first element of the collection.
    ///
    /// - Returns: The first element of the collection if the collection is not empty; otherwise, nil.
    public func popFirst() -> (key: Key, value: Value)? {
        return self.storage.popFirst()
    }
    
    
    
}

// MARK: - Conformance

// MARK: - Conformance -- Collection
extension SCDictionary: Collection {
    
    /// The element type of a dictionary: a tuple containing an individual key-value pair.
    public typealias Element = Dictionary<Key, Value>.Element
    /// The position of a key-value pair in a dictionary.
    public typealias Index = Dictionary<Key, Value>.Index
    /// A type that represents the indices that are valid for subscripting the collection, in ascending order.
    public typealias Indices = Dictionary<Key, Value>.Indices
    
    /// A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool { return self.storage.isEmpty }
    /// The number of elements in the array.
    public var count: Int { return self.storage.count }
    /// The total number of elements that the array can contain without allocating new storage.
    public var capacity: Int { return self.storage.capacity }
    
    /// The position of the first element in a nonempty array.
    public var startIndex: Index { return self.storage.startIndex }
    /// The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index { return self.storage.endIndex }
    /// The indices that are valid for subscripting the collection, in ascending order.
    public var indices: Indices { return self.storage.indices }
    
    /// Accesses the element at the specified position.
    public subscript(position: Index) -> Element { return self.storage[position] }
    
    /// Returns an iterator over the elements of the collection.
    public func makeIterator() -> DictionaryIterator<Key, Value> { return self.storage.makeIterator() }
    /// Returns the position immediately after the given index.
    public func index(after i: Index) -> Index { return self.storage.index(after: i) }
    /// Removes and returns the key-value pair at the specified index.
    ///
    /// - Parameter index: The position of the key-value pair to remove. index must be a valid index of the dictionary, and must not equal the dictionary’s end index.
    /// - Returns: The key-value pair that correspond to index.
    @discardableResult public func remove(at index: Index) -> Element { return self.storage.remove(at: index) }
    
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
    
    /// Accesses the element at the specified position.
    ///
    /// - Parameter index: The position of the element to access. index must be greater than or equal to Zero and less than count.
    /// - Returns: returns the elment at the specific index
    public func item(at index: Int) -> Any {
        let storageIndex = self.storage.index(self.startIndex, offsetBy: index)
        return self.storage[storageIndex]
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
