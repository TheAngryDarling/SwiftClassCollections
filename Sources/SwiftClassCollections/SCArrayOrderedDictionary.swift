//
//  SCArrayOrderedDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-23.
//

import Foundation


/// A class dictionary that keeps order based on when items were added.
/// This is good when you need to keep your dictionaries in a specific order
public final class SCArrayOrderedDictionary<Key, Value> where Key: Hashable {
    
    public typealias Element = (key: Key, value: Value)
    
    /// The index type for dictionary.
    public struct Index: Comparable, Hashable, Strideable {
        fileprivate let offset: Int
        fileprivate init(_ offset: Int) { self.offset = offset }
        
        #if !swift(>=4.1)
        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        /// After Swift 4.0 Hashable can be inferred on structs that have all hashable properties
        /// With Swift 4.2 and above, the moves from hashValue to hash(into:)
        public var hashValue: Int { return self.offset.hashValue }
        #endif
        
        
        /// Returns the distance from this value to the given value, expressed as a
        /// stride.
        ///
        /// If this type's `Stride` type conforms to `BinaryInteger`, then for two
        /// values `x` and `y`, and a distance `n = x.distance(to: y)`,
        /// `x.advanced(by: n) == y`. Using this method with types that have a
        /// noninteger `Stride` may result in an approximation.
        ///
        /// - Parameter other: The value to calculate the distance to.
        /// - Returns: The distance from this value to `other`.
        ///
        /// - Complexity: O(1)
        public func distance(to other: Index) -> Int {
            return other.offset - self.offset
        }
        
        /// Returns a value that is offset the specified distance from this value.
        ///
        /// Use the `advanced(by:)` method in generic code to offset a value by a
        /// specified distance. If you're working directly with numeric values, use
        /// the addition operator (`+`) instead of this method.
        ///
        ///     func addOne<T: Strideable>(to x: T) -> T
        ///         where T.Stride : ExpressibleByIntegerLiteral
        ///     {
        ///         return x.advanced(by: 1)
        ///     }
        ///
        ///     let x = addOne(to: 5)
        ///     // x == 6
        ///     let y = addOne(to: 3.5)
        ///     // y = 4.5
        ///
        /// If this type's `Stride` type conforms to `BinaryInteger`, then for a
        /// value `x`, a distance `n`, and a value `y = x.advanced(by: n)`,
        /// `x.distance(to: y) == n`. Using this method with types that have a
        /// noninteger `Stride` may result in an approximation.
        ///
        /// - Parameter n: The distance to advance this value.
        /// - Returns: A value that is offset from this value by `n`.
        ///
        /// - Complexity: O(1)
        public func advanced(by n: Int) -> Index {
            return Index(self.offset + n)
        }
        
        
        public static func ==(lhs: Index, rhs: Index) -> Bool {
            return lhs.offset == rhs.offset
        }
        
        public static func <(lhs: Index, rhs: Index) -> Bool {
            return lhs.offset < rhs.offset
        }
    }
    
    /// A view of a dictionary's keys.
    public struct Keys : Collection, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// A type representing the sequence's elements.
        public typealias Element = Key
        public typealias Index = SCArrayOrderedDictionary<Key, Value>.Index
        
        private let values: [Element]
        
        /// The position of the first element in a nonempty collection.
        ///
        /// If the collection is empty, `startIndex` is equal to `endIndex`.
        public var startIndex:  Index { return Index(self.values.startIndex) }
        
        /// The collection's "past the end" position---that is, the position one
        /// greater than the last valid subscript argument.
        ///
        /// When you need a range that includes the last element of a collection, use
        /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
        /// creates a range that doesn't include the upper bound, so it's always
        /// safe to use with `endIndex`. For example:
        ///
        ///     let numbers = [10, 20, 30, 40, 50]
        ///     if let index = numbers.firstIndex(of: 30) {
        ///         print(numbers[index ..< numbers.endIndex])
        ///     }
        ///     // Prints "[30, 40, 50]"
        ///
        /// If the collection is empty, `endIndex` is equal to `startIndex`.
        public var endIndex: Index { return Index(self.values.endIndex) }
        
        /// Accesses the element at the specified position.
        ///
        /// The following example accesses an element of an array through its
        /// subscript to print its value:
        ///
        ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
        ///     print(streets[1])
        ///     // Prints "Bryant"
        ///
        /// You can subscript a collection with any valid index other than the
        /// collection's end index. The end index refers to the position one past
        /// the last element of a collection, so it doesn't correspond with an
        /// element.
        ///
        /// - Parameter position: The position of the element to access. `position`
        ///   must be a valid index of the collection that is not equal to the
        ///   `endIndex` property.
        ///
        /// - Complexity: O(1)
        public subscript(index: Index) -> Element { return self.values[index.offset] }
        
        /// The number of values in the dictionary.
        ///
        /// - Complexity: O(1).
        public var count: Int { return self.values.count }
        
        /// A Boolean value indicating whether the collection is empty.
        ///
        /// When you need to check whether your collection is empty, use the
        /// `isEmpty` property instead of checking that the `count` property is
        /// equal to zero. For collections that don't conform to
        /// `RandomAccessCollection`, accessing the `count` property iterates
        /// through the elements of the collection.
        ///
        ///     let horseName = "Silver"
        ///     if horseName.isEmpty {
        ///         print("I've been through the desert on a horse with no name.")
        ///     } else {
        ///         print("Hi ho, \(horseName)!")
        ///     }
        ///     // Prints "Hi ho, Silver!"
        ///
        /// - Complexity: O(1)
        public var isEmpty: Bool { return self.values.isEmpty }
        
        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String { return self.values.description }
        
        /// A textual representation of this instance, suitable for debugging.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(reflecting:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `debugDescription` property for types that conform to
        /// `CustomDebugStringConvertible`:
        ///
        ///     struct Point: CustomDebugStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var debugDescription: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(reflecting: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `debugDescription` property.
        public var debugDescription: String { return self.values.debugDescription }
        
        
        fileprivate init(_ dict: SCArrayOrderedDictionary<Key, Value>) {
            var ary = Array<Element>()
            for kv in dict {
                ary.append(kv.key)
            }
            self.values = ary
            
        }
        
        /// Returns the position immediately after the given index.
        ///
        /// The successor of an index must be well defined. For an index `i` into a
        /// collection `c`, calling `c.index(after: i)` returns the same index every
        /// time.
        ///
        /// - Parameter i: A valid index of the collection. `i` must be less than
        ///   `endIndex`.
        /// - Returns: The index value immediately after `i`.
        public func index(after i: Index) -> Index {
            return Index(self.values.index(after: i.offset))
        }
        
        public static func ==(lhs: Keys, rhs: Keys) -> Bool {
            guard lhs.count == rhs.count else { return false }
            guard !(lhs.count == 0 && rhs.count == 0) else { return true }
            for i in lhs.startIndex..<lhs.endIndex {
                if !(lhs[i] == rhs[i]) { return false }
            }
            return true
        }
        
    }
    
    /// A view of a dictionary's values.
    public struct Values : MutableCollection, CustomStringConvertible, CustomDebugStringConvertible {
        
        /// A type representing the sequence's elements.
        public typealias Element = Value
        public typealias Index = SCArrayOrderedDictionary<Key, Value>.Index
        
        private var values: [Element]
        
        /// The position of the first element in a nonempty collection.
        ///
        /// If the collection is empty, `startIndex` is equal to `endIndex`.
        public var startIndex:  Index { return Index(self.values.startIndex) }
        
        /// The collection's "past the end" position---that is, the position one
        /// greater than the last valid subscript argument.
        ///
        /// When you need a range that includes the last element of a collection, use
        /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
        /// creates a range that doesn't include the upper bound, so it's always
        /// safe to use with `endIndex`. For example:
        ///
        ///     let numbers = [10, 20, 30, 40, 50]
        ///     if let index = numbers.firstIndex(of: 30) {
        ///         print(numbers[index ..< numbers.endIndex])
        ///     }
        ///     // Prints "[30, 40, 50]"
        ///
        /// If the collection is empty, `endIndex` is equal to `startIndex`.
        public var endIndex: Index { return Index(self.values.endIndex) }
        
        /// Accesses the element at the specified position.
        ///
        /// The following example accesses an element of an array through its
        /// subscript to print its value:
        ///
        ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
        ///     print(streets[1])
        ///     // Prints "Bryant"
        ///
        /// You can subscript a collection with any valid index other than the
        /// collection's end index. The end index refers to the position one past
        /// the last element of a collection, so it doesn't correspond with an
        /// element.
        ///
        /// - Parameter position: The position of the element to access. `position`
        ///   must be a valid index of the collection that is not equal to the
        ///   `endIndex` property.
        ///
        /// - Complexity: O(1)
        public subscript(index: Index) -> Element {
            get { return self.values[index.offset] }
            set {
                self.values[index.offset] = newValue
                //let k = self.values[index.offset]
                //self.dict.storage[index.offset] = (k, newValue)
            }
        }
        
        /// The number of values in the dictionary.
        ///
        /// - Complexity: O(1).
        public var count: Int { return self.values.count }
        
        /// A Boolean value indicating whether the collection is empty.
        ///
        /// When you need to check whether your collection is empty, use the
        /// `isEmpty` property instead of checking that the `count` property is
        /// equal to zero. For collections that don't conform to
        /// `RandomAccessCollection`, accessing the `count` property iterates
        /// through the elements of the collection.
        ///
        ///     let horseName = "Silver"
        ///     if horseName.isEmpty {
        ///         print("I've been through the desert on a horse with no name.")
        ///     } else {
        ///         print("Hi ho, \(horseName)!")
        ///     }
        ///     // Prints "Hi ho, Silver!"
        ///
        /// - Complexity: O(1)
        public var isEmpty: Bool { return self.values.isEmpty }
        
        /// A textual representation of this instance.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(describing:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `description` property for types that conform to
        /// `CustomStringConvertible`:
        ///
        ///     struct Point: CustomStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var description: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(describing: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `description` property.
        public var description: String { return self.values.description }
        
        /// A textual representation of this instance, suitable for debugging.
        ///
        /// Calling this property directly is discouraged. Instead, convert an
        /// instance of any type to a string by using the `String(reflecting:)`
        /// initializer. This initializer works with any type, and uses the custom
        /// `debugDescription` property for types that conform to
        /// `CustomDebugStringConvertible`:
        ///
        ///     struct Point: CustomDebugStringConvertible {
        ///         let x: Int, y: Int
        ///
        ///         var debugDescription: String {
        ///             return "(\(x), \(y))"
        ///         }
        ///     }
        ///
        ///     let p = Point(x: 21, y: 30)
        ///     let s = String(reflecting: p)
        ///     print(s)
        ///     // Prints "(21, 30)"
        ///
        /// The conversion of `p` to a string in the assignment to `s` uses the
        /// `Point` type's `debugDescription` property.
        public var debugDescription: String { return self.values.debugDescription }
        
        
        fileprivate init(_ dict: SCArrayOrderedDictionary<Key, Value>) {
            var ary = Array<Element>()
            for kv in dict {
                ary.append(kv.value)
            }
            self.values = ary
        }
        
        /// Returns the position immediately after the given index.
        ///
        /// The successor of an index must be well defined. For an index `i` into a
        /// collection `c`, calling `c.index(after: i)` returns the same index every
        /// time.
        ///
        /// - Parameter i: A valid index of the collection. `i` must be less than
        ///   `endIndex`.
        /// - Returns: The index value immediately after `i`.
        public func index(after i: Index) -> Index {
            return Index(self.values.index(after: i.offset))
        }
        
    }
    
    /// Initial capacity of a Dictionary
    private let INIT_CAP: Int = 3
    
    /// Minimum capacity of a Dictionary
    private let MINIMUN_CAP: Int = 12
    
    /// Actual storage of items
    fileprivate var storage: Array<(Key, Value)>
    
    /// A collection containing just the keys of the dictionary.
    public var keys: Keys  { return Keys(self) }
    /// A collection containing just the values of the dictionary.
    public var values: Values {
        get { return Values(self) }
        set {
            for (idx, val) in newValue.enumerated() {
                let k = self.storage[idx].0
                self.storage[idx] = (k, val)
            }
        }
    }
    
    
    
    fileprivate init(_ dictionary: Dictionary<Key, Value>) {
        self.storage = Array<(Key, Value)>()
        self.storage.reserveCapacity(INIT_CAP)
        for (k,v) in dictionary {
            self.storage.append((k,v))
        }
        
    }
    
    fileprivate init(_ dictionary: SCArrayOrderedDictionary<Key, Value>) {
        self.storage = dictionary.storage
        self.storage.reserveCapacity(INIT_CAP)
    }
    
    fileprivate init(_ array: Array<(Key, Value)>) {
        self.storage = array
        self.storage.reserveCapacity(INIT_CAP)
    }
    
    /// Creates an empty dictionary.
    public init() {
        self.storage = Array<(Key, Value)>()
        self.storage.reserveCapacity(INIT_CAP)
    }
    
    /// Creates an empty dictionary with preallocated space for at least the specified number of elements.
    ///
    /// - Parameter minimumCapacity: The minimum number of key-value pairs that the newly created dictionary should be able to store without reallocating its storage buffer.
    public init(minimumCapacity: Int) {
        self.storage = Array<(Key, Value)>()
        self.storage.reserveCapacity(minimumCapacity)
    }
    
    /// Creates a new dictionary from the key-value pairs in the given sequence.
    ///
    /// - Parameter keysAndValues: A sequence of key-value pairs to use for the new dictionary. Every key in keysAndValues must be unique.
    public init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value) {
        self.storage = Array<(Key, Value)>(keysAndValues)
        self.storage.reserveCapacity(INIT_CAP)
    }
    
    /// Creates a new dictionary from the key-value pairs in the given sequence, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameter:
    ///   - keysAndValues: A sequence of key-value pairs to use for the new dictionary.
    ///   - combine: A closure that is called with the values for any duplicate keys that are encountered. The closure returns the desired value for the final dictionary.
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.storage = Array<(Key, Value)>()
        self.storage.reserveCapacity(INIT_CAP)
        for v in keysAndValues {
            if let idx = self.index(forKey: v.0) {
                self[idx] = (v.0, try combine(self[idx].value, v.1))
            } else {
                self.storage.append((v.0, v.1))
            }
        }
    }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    public subscript(key: Key) -> Value? {
        get {
            for v in self.storage {
                if v.0 == key { return v.1}
            }
            return nil
        }
        set {
            var hasFound: Bool = false
            for i in 0..<self.storage.count {
                if self.storage[i].0 == key {
                    hasFound = true
                    if let v = newValue {
                        self.storage[i] = (key, v)
                    } else {
                        self.storage.remove(at: i)
                    }
                }
            }
            if let v = newValue, !hasFound {
                self.storage.append((key, v))
            }
        }
    }
    
    /// Accesses the value with the given key. If the dictionary doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the dictionary.
    ///
    /// - Parameters:
    ///   - key: The key the look up in the dictionary.
    ///   - defaultValue: The default value to use if key doesn’t exist in the dictionary.
    /// - Returns: The value associated with key in the dictionary; otherwise,defaultValue`
    public subscript(key: Key,
                     default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            for v in self.storage {
                if v.0 == key { return v.1}
            }
            return defaultValue()
        }
        set {
            var hasFound: Bool = false
            for i in 0..<self.storage.count {
                if self.storage[i].0 == key {
                    hasFound = true
                    self.storage[i] = (key, newValue)
                }
            }
            if !hasFound {
                self.storage.append((key, newValue))
            }
        }
    }
    
    
    
    /// Accesses the value associated with the given key for reading.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    public func index(forKey key: Key) -> Index? {
        for i in 0..<self.storage.count {
            if self.storage[i].0 == key { return Index(i) }
        }
        return nil
    }
    
    /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with value. If key already exists in the dictionary, value replaces the existing associated value. If key isn’t already a key of the dictionary, the (key, value) pair is added.
    /// - Returns: The value that was replaced, or nil if a new key-value pair was added.
    @discardableResult public func updateValue(_ value: Value, forKey key: Key) -> Value? {
        var oldValue: Value? = nil
        var hasFound: Bool = false
        for i in 0..<self.storage.count {
            if self.storage[i].0 == key {
                hasFound = true
                oldValue = self.storage[i].1
                self.storage[i] = (key, value)
            }
        }
        if !hasFound {
            self.storage.append((key, value))
        }
        
        return oldValue
    }
    
    /// Merges the given dictionary into this dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    public func merge(_ other: SCArrayOrderedDictionary<Key, Value>,
                      uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        for (k,v) in other {
            if let oV = self[k] {
                _ = self.updateValue(try combine(oV,v), forKey: k)
            } else {
                self.storage.append((k,v))
            }
        }
    }
    
    /// Merges the given dictionary into this dictionary, using a combining closure to determine the value for any duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    public func merge<S>(_ other: S,
                         uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        for (k,v) in other {
            if let oV = self[k] {
                _ = self.updateValue(try combine(oV,v), forKey: k)
            } else {
                self.storage.append((k,v))
            }
        }
    }
    
    /// Creates a dictionary by merging the given dictionary into this dictionary, using a combining closure to determine the value for duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    public func merging(_ other: SCArrayOrderedDictionary<Key, Value>,
                        uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCArrayOrderedDictionary<Key, Value> {
        let rtn = SCArrayOrderedDictionary<Key, Value>(self.storage)
        for (k,v) in other {
            if let oV = rtn[k] {
                _ = rtn.updateValue(try combine(oV,v), forKey: k)
            } else {
                rtn.storage.append((k,v))
            }
        }
        return rtn
        
    }
    
    /// Creates a dictionary by merging the given dictionary into this dictionary, using a combining closure to determine the value for duplicate keys.
    ///
    /// - Parameters:
    ///   - other: A dictionary to merge.
    ///   - combine: A closure that takes the current and new values for any duplicate keys. The closure returns the desired value for the final dictionary.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    public func merging<S>(_ other: S,
                           uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> SCArrayOrderedDictionary<Key, Value> where S : Sequence, S.Element == (Key, Value) {
        let rtn = SCArrayOrderedDictionary<Key, Value>(self.storage)
        for (k,v) in other {
            if let oV = rtn[k] {
                _ = rtn.updateValue(try combine(oV,v), forKey: k)
            } else {
                rtn.storage.append((k,v))
            }
        }
        return rtn
    }
    
    /// Reserves enough space to store the specified number of key-value pairs.
    ///
    /// - Parameter minimumCapacity: The requested number of key-value pairs to store.
    public func reserveCapacity(_ minimumCapacity: Int) {
        guard minimumCapacity >= MINIMUN_CAP else {
            self.storage.reserveCapacity(MINIMUN_CAP)
            return
        }
        self.storage.reserveCapacity(minimumCapacity)
    }
    
    /// Returns a new dictionary containing the key-value pairs of the dictionary that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its argument and returns a Boolean value indicating whether the pair should be included in the returned dictionary.
    /// - Returns: A dictionary of the key-value pairs that isIncluded allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> SCArrayOrderedDictionary<Key, Value> {
        let rtn: SCArrayOrderedDictionary<Key, Value> = SCArrayOrderedDictionary<Key, Value>()
        for v in self.storage {
            if try isIncluded(v) {
                rtn.storage.append((v.0, v.1))
            }
        }
        return rtn
    }
    
    /// Removes the given key and its associated value from the dictionary.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or nil if the key was not present in the dictionary.
    @discardableResult public func removeValue(forKey key: Key) -> Value? {
       
        for i in 0..<self.storage.count {
            if self.storage[i].0 == key {
                let oldValue = self.storage[i].1
                self.storage.remove(at: i)
                return oldValue
            }
        }
        
        return nil
    }
    
    /// Removes all key-value pairs from the dictionary.
    ///
    /// - Parameter keepCapacity: Whether the dictionary should keep its underlying buffer. If you pass true, the operation preserves the buffer capacity that the collection has, otherwise the underlying buffer is released. The default is false.
    public func removeAll(keepingCapacity keepCapacity: Bool = false) { self.storage.removeAll(keepingCapacity: keepCapacity) }
    
    /// Returns a new dictionary containing the keys of this dictionary with the values transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms a value. transform accepts each value of the dictionary as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the keys and transformed values of this dictionary.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> SCArrayOrderedDictionary<Key, T> {
        let rtn: SCArrayOrderedDictionary<Key, T> = SCArrayOrderedDictionary<Key, T>()
        for v in self.storage {
            rtn.storage.append((v.0, try transform(v.1)))
        }
        return rtn
    }
    
    /// Removes and returns the first element of the collection.
    ///
    /// - Returns: The first element of the collection if the collection is not empty; otherwise, nil.
    public func popFirst() -> (key: Key, value: Value)? {
        guard self.storage.count > 0 else { return nil }
        return self.storage.removeFirst()
    }
 
}


// MARK: - Conformance -- Collection
extension SCArrayOrderedDictionary: Collection {
    
    // A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool { return self.storage.isEmpty }
    // The number of elements in the array.
    public var count: Int { return self.storage.count }
    // The total number of elements that the array can contain without allocating new storage.
    public var capacity: Int { return self.storage.capacity }
    
    // The position of the first element in a nonempty array.
    public var startIndex: Index { return Index(self.storage.startIndex) }
    // The array’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index { return Index(self.storage.endIndex) }
    // The indices that are valid for subscripting the collection, in ascending order.
    //public var indices: Indices { return self.storage.indices }
    
    // Accesses the element at the specified position.
    public subscript(position: Index) -> Element {
        get { return self.storage[position.offset] }
        set { self.storage[position.offset] = newValue }
    }
    
    // Returns the position immediately after the given index.
    public func index(after i: Index) -> Index { return Index(self.storage.index(after: i.offset)) }
    // Removes and returns the element at the specified position.
    public func remove(at index: Index) -> Element { return self.storage.remove(at: index.offset) }
    
}

// MARK: - Conformance -- CustomStringConvertible
extension SCArrayOrderedDictionary: CustomStringConvertible {
    public var description: String {
        func escapeValuesForString(_ value: Any) -> String {
            guard let s = value as? String else { return "\(value)" }
            return "\"\(s)\""
        }
        var rtn: String = "["
        
        for i in self.startIndex..<self.endIndex {
            if i > self.startIndex { rtn += ", " }
            let v = self[i]
            rtn += escapeValuesForString(v.key)
            rtn += ": "
            rtn += escapeValuesForString(v.value)
        }
        
        rtn += "]"
        
        return rtn
    }
}

// MARK: - Conformance -- SMutableArray
extension SCArrayOrderedDictionary: SMutableDictionary {
    
    public convenience init<D>(_ dictionary: D) where D : SDictionary, Key == D.Key, Value == D.Value {
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
        return self.storage[index]
    }
}

// MARK: - Conformance -- ReEncapsulatable
extension SCArrayOrderedDictionary: ReEncapsulatableCollecton, ReEncapsulatableDictionary {
    public static var ReEncapsulateType: ReEncapsulateDictionary {
        return .arrayOrderedDictionary
    }
    
    
}

// MARK: - Conditional conformance
#if swift(>=4.1)
extension SCArrayOrderedDictionary where Key: Hashable  {
    private struct SCArrayOrderedDictionaryCodingKey: CodingKey {
        
        public var stringValue: String
        public var intValue: Int?
        
        public init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        public init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        public init(stringValue: String, intValue: Int?) {
            self.stringValue = stringValue
            self.intValue = intValue
        }
        
        public init(index: Int) {
            self.stringValue = "Index \(index)"
            self.intValue = index
        }
        
    }
}
// MARK: - Conformance -- Encodable
extension SCArrayOrderedDictionary: Encodable where Key: Encodable, Key: Hashable, Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SCArrayOrderedDictionaryCodingKey.self)
        for kv in self {
            if let iK = kv.key as? Int {
                try container.encode(kv.value, forKey: SCArrayOrderedDictionaryCodingKey(index: iK))
            } else if let sK = kv.key as? String {
                try container.encode(kv.value, forKey: SCArrayOrderedDictionaryCodingKey(stringValue: sK))
            } else {
                fatalError("Unsupported encoding key type of: \(Key.self)")
            }
        }
    }
}

// MARK: - Conformance -- Decodable
extension SCArrayOrderedDictionary: Decodable where Key: Decodable, Key: Hashable, Value: Decodable {
    public convenience init(from decoder: Decoder) throws {
        var ary = Array<(Key, Value)>()
        let container = try decoder.container(keyedBy: SCArrayOrderedDictionaryCodingKey.self)
        
        let keys = container.allKeys
        for k in keys {
            let v = try container.decode(Value.self, forKey: k)
            if let iK = k.intValue, Key.self == Int.self {
                ary.append((iK as! Key, v))
            } else if Key.self == String.self {
                ary.append((k.stringValue as! Key, v))
            } else {
                fatalError("Unsupported encoding key type of: \(Key.self)")
            }
        }
        self.init(ary)
    }
}


// MARK: - Conformance -- Equatable
extension SCArrayOrderedDictionary: Equatable where Key: Equatable, Value: Equatable {
    public static func == (lhs: SCArrayOrderedDictionary, rhs: SCArrayOrderedDictionary) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for idx in lhs.startIndex..<lhs.endIndex {
            let lhsV = lhs[idx]
            let rhsV = rhs[idx]
            if !(lhsV.key == rhsV.key && lhsV.value == rhsV.value) { return false }
        }
        return true
    }
    public static func ~= (lhs: SCArrayOrderedDictionary, rhs: SCArrayOrderedDictionary) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for (k,v) in lhs {
            guard let rhsv = rhs[k] else { return false }
            if v != rhsv { return false }
        }
        return true
    }
}

#if swift(>=4.2)
// MARK: - Conformance -- Hashable
extension SCArrayOrderedDictionary: Hashable where Key: Hashable, Value: Hashable {
    public var hashValue: Int {
        var h = Hasher()
        self.hash(into: &h)
        return h.finalize()
    }


    public func hash(into hasher: inout Hasher) {
        for v in self {
            v.0.hash(into: &hasher)
            v.1.hash(into: &hasher)
        }
    }
}
#endif

#endif


// MARK: - General equatable operators
public func ==<Key, Value, Dict>(lhs: Dict, rhs: SCArrayOrderedDictionary<Key, Value>) -> Bool where Value: Equatable, Dict: SDictionary, Dict.Key == Key, Dict.Value == Value {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in lhs {
        guard let rhsv = rhs[k] else { return false }
        if v != rhsv { return false }
    }
    return true
}
public func ==<Key, Value, Dict>(lhs: SCArrayOrderedDictionary<Key, Value>, rhs: Dict) -> Bool where Value: Equatable, Dict: SDictionary, Dict.Key == Key, Dict.Value == Value {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in lhs {
        guard let rhsv = rhs[k] else { return false }
        if v != rhsv { return false }
    }
    return true
}

// MARK: - General equivalent operator
public func ==<Key,Value>(lhs: Dictionary<Key, Value>, rhs: SCArrayOrderedDictionary<Key, Value>) -> Bool where Value: Equatable {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in lhs {
        guard let rhsv = rhs[k] else { return false }
        if v != rhsv { return false }
    }
    return true
}
public func ==<Key,Value>(lhs: SCArrayOrderedDictionary<Key, Value>, rhs: Dictionary<Key, Value>) -> Bool where Value: Equatable {
    guard lhs.count == rhs.count else { return false }
    for (k,v) in rhs {
        guard let lhsv = lhs[k] else { return false }
        if v != lhsv { return false }
    }
    return true
}
