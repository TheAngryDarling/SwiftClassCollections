//
//  SCArray.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-23.
//

import Foundation

/*
 A class that provides the same functionality as a regular swift Array
 This privides a typed based replacement for NSArray and NSMutableArray
*/
public final class SCArray<Element> {
    fileprivate var storage: Array<Element>
    
    fileprivate init(_ array: Array<Element>) { self.storage = array }
    
    // This is equivalent to initializing with an empty array literal. For example
    public init() { self.storage = Array<Element>() }
    // Creates a new instance of a collection containing the elements of a sequence.
    public init<S>(_ s: S) where S : Sequence, Element == S.Element {
        self.storage = Array<Element>(s)
    }
    // Creates a new collection containing the specified number of a single, repeated value.
    public init(repeating repeatedValue: Element, count: Int) {
        self.storage = Array<Element>(repeating: repeatedValue, count: count)
    }
    
    
    // Adds a new element at the end of the array.
    public func append(_ newElement: Element) { self.storage.append(newElement) }
    // Adds the elements of a sequence or collection to the end of this collection.
    public func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        self.storage.append(contentsOf: newElements)
    }
    
    //public func add(_ element: Element) { self.append(element) }
    
    // Inserts a new element into the collection at the specified position.
    public func insert(_ newElement: Element, at i: Int) { self.storage.insert(newElement, at: i) }
    // Inserts the elements of a sequence into the collection at the specified position.
    public func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, Element == C.Element {
        self.storage.insert(contentsOf: newElements, at: i)
    }
    // Replaces a range of elements with the elements in the specified collection.
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where Element == C.Element, C : Collection {
        self.storage.replaceSubrange(subrange, with: newElements)
    }
    // Replaces the specified subrange of elements with the given collection.
    public func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, Element == C.Element, Array<Element>.Index == R.Bound {
        self.storage.replaceSubrange(subrange, with: newElements)
    }
    // Reserves enough space to store the specified number of elements.
    public func reserveCapacity(_ minimumCapacity: Int) { self.storage.reserveCapacity(minimumCapacity) }
    // Returns the minimum element in the sequence, using the given predicate as the comparison between elements.
    public func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try self.storage.min(by: areInIncreasingOrder)
    }
    // Returns the maximum element in the sequence, using the given predicate as the comparison between elements.
    public func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try self.storage.max(by: areInIncreasingOrder)
    }
    
    // Calls a closure with a pointer to the array’s contiguous storage.
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Array<Element>.Element>) throws -> R) rethrows -> R {
        return try self.storage.withUnsafeBufferPointer(body)
    }
    // Calls the given closure with a pointer to the array’s mutable contiguous storage.
    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Array<Element>.Element>) throws -> R) rethrows -> R {
        return try self.storage.withUnsafeMutableBufferPointer(body)
    }
    // Calls the given closure with a pointer to the underlying bytes of the array’s contiguous storage.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try self.storage.withUnsafeBytes(body)
    }
    // Calls the given closure with a pointer to the underlying bytes of the array’s mutable contiguous storage.
    public func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try self.storage.withUnsafeMutableBytes(body)
    }
}


extension SCArray where Element: Comparable {
    func min() -> Element? { return self.storage.min() }
    func max() -> Element? { return self.storage.max() }
}

// MARK: - Operators
extension SCArray {
    public static func + <Other>(lhs: Other,
                                 rhs: SCArray<Element>) -> SCArray<Element> where Other : Sequence, Element == Other.Element {
        let ary: Array<Element> = Array<Element>(lhs) + rhs.storage
        return SCArray<Element>(ary)
    }
    public static func + <Other>(lhs: SCArray<Element>,
                                 rhs: Other) -> SCArray<Element> where Other : Sequence, Element == Other.Element {
        let ary: Array<Element> = lhs.storage + rhs
        return SCArray<Element>(ary)
    }
    public static func + <Other>(lhs: SCArray<Element>,
                                 rhs: Other) -> SCArray<Element> where Other : RangeReplaceableCollection, Element == Other.Element {
        let ary: Array<Element> = lhs.storage + rhs
        return SCArray<Element>(ary)
        
    }
    
    public static func += <Other>(lhs: SCArray<Element>, rhs: Other) where Other : Sequence, Element == Other.Element {
        lhs.append(contentsOf: rhs)
    }
}

// MARK: - Conformance

// MARK: - Conformance -- MutableCollection
extension SCArray: MutableCollection {
    public typealias Index = Array<Element>.Index
    public typealias Indices = Array<Element>.Indices
    
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
    public subscript(position: Index) -> Element {
        get { return self.storage[position] }
        set { self.storage[position] = newValue }
    }
    
    // Returns an iterator over the elements of the collection.
    public func makeIterator() -> IndexingIterator<Array<Element>> { return self.storage.makeIterator() }
    // Returns the position immediately after the given index.
    public func index(after i: Index) -> Index { return self.storage.index(after: i) }
    // Removes and returns the element at the specified position.
    public func remove(at index: Index) -> Element { return self.storage.remove(at: index) }
}

// MARK: - Conformance -- RandomAccessCollection
extension SCArray: RandomAccessCollection { }

// MARK: - Conformance -- RangeReplacableCollection
extension SCArray: RangeReplaceableCollection { }

// MARK: - Conformance -- ExpressibleByArrayLiteral
extension SCArray: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - Conformance -- CustomStringConvertible, CustomDebugStringConvertible
extension SCArray: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { return self.storage.description }
    public var debugDescription: String { return self.storage.debugDescription }
}

// MARK: - Conformance -- CustomReflectable
extension SCArray: CustomReflectable {
    public var customMirror: Mirror { return self.storage.customMirror }
}


// MARK: - Conformance -- SMutableArray
extension SCArray: SMutableArray { }


// MARK: - Conditional conformance
#if swift(>=4.1)

// MARK: - Conformance -- Encodable
extension SCArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        try self.storage.encode(to: encoder)
    }
}

// MARK: - Conformance -- Decodable
extension SCArray: Decodable where Element: Decodable {
    public convenience init(from decoder: Decoder) throws {
        let d = try Array<Element>(from: decoder)
        self.init(d)
    }
}


// MARK: - Conformance -- Equatable
extension SCArray: Equatable where Element: Equatable {
    public static func == (lhs: SCArray, rhs: SCArray) -> Bool {
        return lhs.storage == rhs.storage
    }
    public func contains(_ element: Element) -> Bool {
        return self.storage.contains(element)
    }
}

#if swift(>=4.2)
// MARK: - Conformance -- Hashable
extension SCArray: Hashable where Element: Hashable {
    public var hashValue: Int { return self.storage.hashValue }


    public func hash(into hasher: inout Hasher) {
        return self.storage.hash(into: &hasher)
    }

}
#endif


#endif

// MARK - Base equatable operators
public func ==<Element>(lhs: [Element], rhs: SCArray<Element>) -> Bool  where Element: Equatable {
    return lhs == rhs.storage
}
public func ==<Element>(lhs: SCArray<Element>, rhs: [Element]) -> Bool where Element: Equatable {
    return lhs.storage == rhs
}

public func ~=<Element>(lhs: [Element], rhs: SCArray<Element>) -> Bool  where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    for v in lhs {
        if !rhs.contains(v) { return false }
    }
    return true
}
public func ~=<Element>(lhs: SCArray<Element>, rhs: [Element]) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    for v in lhs {
        if !rhs.contains(v) { return false }
    }
    return true
}


// MARK - Slice Equatable Operators
public func ==<Element>(lhs: Slice<SCArray<Element>>, rhs: Slice<Array<Element>>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}
public func ==<Element>(lhs: Slice<Array<Element>>, rhs: Slice<SCArray<Element>>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}
public func ==<Element>(lhs: ArraySlice<SCArray<Element>>, rhs: ArraySlice<Array<Element>>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}
public func ==<Element>(lhs: ArraySlice<Array<Element>>, rhs: ArraySlice<SCArray<Element>>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}

public func ==<Element>(lhs: Slice<SCArray<Element>>, rhs: ArraySlice<Element>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}

public func ==<Element>(lhs: ArraySlice<Element>, rhs: Slice<SCArray<Element>>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}

#if !swift(>=4.1) && !_runtime(_ObjC)
public func ==<Element>(lhs: MutableRangeReplaceableRandomAccessSlice<SCArray<Element>>, rhs: ArraySlice<Element>) -> Bool where Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var lhsIndex = lhs.startIndex
    var rhsIndex = rhs.startIndex
    for _ in 0..<lhs.count {
        if !(lhs[lhsIndex] == rhs[rhsIndex]) { return false}
        lhsIndex = lhs.index(after: lhsIndex)
        rhsIndex = rhs.index(after: rhsIndex)
    }
    return true
}
#endif
