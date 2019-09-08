//
//  SDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-30.
//
// Protocol definitions to define any dictionary or mutable dictionary

import Foundation


/// Protocol defining a Swift Dictionary.
/// This is basicaly a Collection with a new name for standardization, adding methods and properties specific to Dictionaries
public protocol SDictionary: Collection, SAnyDictionary where Element == (key: Key, value: Value)  {
    
    associatedtype Key: Hashable
    associatedtype Value
    
    /// A view of a dictionary’s keys.
    associatedtype Keys: Collection, Equatable where Keys.Element == Key, Keys.Index == Self.Index
    /// A view of a dictionary’s values.
    associatedtype Values : Collection where Values.Element == Value, Values.Index == Self.Index

    /// A collection containing just the keys of the dictionary.
    var keys: Keys { get }
    /// A collection containing just the values of the dictionary.
    var values: Values { get }
    /// The first element of the collection.
    var first: Element? { get }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    subscript(key: Key) -> Value? { get }
    subscript(index: Index) -> Element { get }
    /// Accesses the value with the given key. If the dictionary doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the dictionary.
    ///
    /// - Parameters:
    ///   - key: The key the look up in the dictionary.
    ///   - defaultValue: The default value to use if key doesn’t exist in the dictionary.
    /// - Returns: The value associated with key in the dictionary; otherwise,defaultValue`
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get }
    
    /// Creates an empty dictionary.
    init()
    /// Creates a new dictionary from the key-value pairs in the given sequence.
    ///
    /// - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary. Every key in keysAndValues must be unique.
    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
    /// Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameter:
    ///   - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
    init<S>(_ keysAndValues: S,
            uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value)
    /// Creates a new dictionary from the contents of another object that implements SDictionary
    ///
    /// - Parameter dictionary: Object that implements SDictionary to copy items from
    init<D>(_ dictionary: D) where D: SDictionary, D.Key == Key, D.Value == Value
    
}

public extension SDictionary {
    /// The Key Type constraint on this dictionary
    var keyType: Any.Type { return Key.self }
    /// The Value Type constraint on this dictionary
    var valueType: Any.Type { return Value.self }
    
    /// Accesses the value associated with the given key for reading.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    func item(forKey key: Any) -> Any? {
        guard let k = key as? Key else {
            fatalError("Unable to cast '\(key)' to \(Key.self)")
        }
        return self[k]
    }
}

internal extension SDictionary {
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary, arraysTo: ReEncapsulateArray) -> Any {
        
        let dict = SCArrayOrderedDictionary<Key, Value>() // We use SCArrayOrderedDictionary to keep the same order as the origional dictionary
        for (k,v) in self {
            guard let r = v as? ReEncapsulatableCollecton else {
                dict[k] = v
                continue
            }
            dict[k] = (r._reencapsulate(dictionariesTo: dictionariesTo, arraysTo: arraysTo) as! Value)
        }
        switch dictionariesTo {
            case .dictionary: return Dictionary<Key, Value>(dict)
            case .classDictionary: return SCDictionary<Key, Value>(dict)
            case .arrayOrderedDictionary: return dict
        }
    }
    
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary) -> Any {
        let dict = SCArrayOrderedDictionary<Key, Value>() // We use SCArrayOrderedDictionary to keep the same order as the origional dictionary
        for (k,v) in self {
            guard let r = v as? ReEncapsulatableCollecton else {
                dict[k] = v
                continue
            }
            dict[k] = (r._reencapsulate(dictionariesTo: dictionariesTo) as! Value)
        }
        switch dictionariesTo {
            case .dictionary: return Dictionary<Key, Value>(dict)
            case .classDictionary: return SCDictionary<Key, Value>(dict)
            case .arrayOrderedDictionary: return dict
        }
    }
    
    func _reencapsulate(arraysTo: ReEncapsulateArray) -> Any {
        let dict = SCArrayOrderedDictionary<Key, Value>() // We use SCArrayOrderedDictionary to keep the same order as the origional dictionary
        for (k,v) in self {
            guard let r = v as? ReEncapsulatableCollecton else {
                dict[k] = v
                continue
            }
            dict[k] = (r._reencapsulate(arraysTo: arraysTo) as! Value)
        }
        return type(of: self).init(dict)
    }
}

public extension SDictionary where Value == Any {
    /// Re-Encapsulate any Array/Dictionary from one type to another
    ///
    /// - Parameters:
    ///   - dictionariesTo: what object to build dictionaries into
    ///   - arraysTo: what object to build arrays into
    /// - Returns: The newly created object for the given types
    func reencapsulate(dictionariesTo: ReEncapsulateDictionary, arraysTo: ReEncapsulateArray) -> Any {
        return self._reencapsulate(dictionariesTo: dictionariesTo, arraysTo: arraysTo)
    }
    
    /// Re-Encapsulate any dictionaries from one type to another
    ///
    /// - Parameters:
    ///   - dictionariesTo: what object to build dictionaries into
    /// - Returns: The newly created object for the given types
    func reencapsulate(dictionariesTo: ReEncapsulateDictionary) -> Any {
        return self._reencapsulate(dictionariesTo: dictionariesTo)
    }
    
    /// Re-Encapsulate any arrays from one type to another
    ///
    /// - Parameters:
    ///   - arraysTo: what object to build arrays into
    /// - Returns: The newly created object for the given types
    func reencapsulate(arraysTo: ReEncapsulateArray) -> Any {
        return self._reencapsulate(arraysTo: arraysTo)
    }
    
    /// Provides a defualt to reencapsulate which converts object to standard swift arrays and dictionaries
    func reencapsulateToSwift() -> Any {
        return self._reencapsulate(dictionariesTo: .dictionary, arraysTo: .array)
    }
    
    /// Re-Encapsulate the array to a difference container type
    ///
    /// - Parameters:
    ///   - dictionaries: what object type to build dictionaries into
    ///   - arrays: what object type to build arrays into
    /// - Returns: The newly created object for the given types
    func reencapsulate<A, D>(dictionaries: D.Type, arrays: A.Type) -> D where D: ReEncapsulatableDictionary, A: ReEncapsulatableArray, D.Key == Key, D.Value == Value {
        return self.reencapsulate(dictionariesTo: D.ReEncapsulateType, arraysTo: A.ReEncapsulateType) as! D
    }
    
    /// Re-Encapsulate the dictionary and any child dictionaries to a difference container type
    ///
    /// - Parameters:
    ///   - dictionaries: what object type to build dictionaries into
    /// - Returns: The newly created object for the given types
    func reencapsulate<D>(dictionaries: D.Type) -> D where D: ReEncapsulatableDictionary {
        return self.reencapsulate(dictionariesTo: D.ReEncapsulateType) as! D
    }
    
    /// Re-Encapsulate any child arrays to a difference container type
    ///
    /// - Parameters:
    ///   - arrays: what object type to build arrays into
    /// - Returns: The newly created object for the given types
    func reencapsulate<A>(arrays: A.Type) -> Self where A: ReEncapsulatableArray, A.Element == Element {
        return self.reencapsulate(arraysTo: A.ReEncapsulateType) as! Self
    }
}

/// Protocol defining a Swift mutable Dictionary.
/// This is bascially an SDictionary with mutable properties and methods
public protocol SMutableDictionary: SDictionary where Values: MutableCollection {
    
    /// A collection containing just the values of the dictionary.
    var values: Values { get set }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// - Parameter:
    ///   - key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    subscript(key: Key) -> Value? { get set }
    /// Accesses the value with the given key. If the dictionary doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the dictionary.
    ///
    /// - Parameters:
    ///   - key: The key the look up in the dictionary.
    ///   - defaultValue: The default value to use if key doesn’t exist in the dictionary.
    /// - Returns: The value associated with key in the dictionary; otherwise,defaultValue`.
    subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get set }
    
    /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with value. If key already exists in the dictionary, value replaces the existing associated value. If key isn’t already a key of the dictionary, the (key, value) pair is added.
    /// - Returns: The value that was replaced, or nil if a new key-value pair was added.
    @discardableResult mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or nil if the key was not present in the dictionary.
    @discardableResult mutating func removeValue(forKey key: Key) -> Value?
    /// Removes and returns the key-value pair at the specified index.
    ///
    /// - Parameter index: The position of the key-value pair to remove. index must be a valid index of the dictionary, and must not equal the dictionary’s end index.
    /// - Returns: The key-value pair that correspond to index.
    @discardableResult mutating func remove(at index: Index) -> Element
    /// Removes all key-value pairs from the dictionary.
    ///
    /// - Parameter keepCapacity: Whether the dictionary should keep its underlying buffer. If you pass true, the operation preserves the buffer capacity that the collection has, otherwise the underlying buffer is released. The default is false.
    mutating func removeAll(keepingCapacity keepCapacity: Bool)
}

public extension SMutableDictionary {
    var elementType: Any.Type { return Element.self }
    /// Removes all key-value pairs from the dictionary.
    mutating func removeAll() {
        self.removeAll(keepingCapacity: false)
    }
}


public func ==<DictA, DictB>(lhs: DictA, rhs: DictB) -> Bool where DictA: SDictionary, DictB: SDictionary, DictA.Key == DictB.Key, DictA.Value == DictB.Value, DictA.Value: Equatable {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in lhs {
        guard let rhsv = rhs[k] else { return false }
        if v != rhsv { return false }
    }
    return true
}


// Mark: - Implementations
extension Dictionary: SMutableDictionary, SAnyDictionary {
    
    public init<D>(_ dictionary: D) where D: SDictionary, D.Key == Key, D.Value == Value {
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
        let storageIndex = self.index(self.startIndex, offsetBy: index)
        return self[storageIndex]
    }
}

