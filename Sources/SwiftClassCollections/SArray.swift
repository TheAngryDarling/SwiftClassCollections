//
//  SArray.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-03-30.
//
// Protocol definitions to define any array or mutable array


import Foundation


/// Protocol defining a Swift Array.  This is basicaly a Collection with a new name for standardization
public protocol SArray: Collection, SAnyArray where Index == Int {
    init()
    init<S>(_ s: S) where S : Sequence, Element == S.Element
    init(repeating repeatedValue: Element, count: Int)
}

extension SArray {
    public var elementType: Any.Type { return Element.self }
    public func item(at index: Int) -> Any {
        return self[index]
    }
}


/// Protocol defining a Swift mutable Array.
/// This is bascially a MutableCollection + SArray with a new name for  standardization
public protocol SMutableArray: SArray, MutableCollection, RangeReplaceableCollection { }

// MARK - Generic equatable operators
public func ==<Ary, Element>(lhs: Ary, rhs: Array<Element>) -> Bool where Ary: SArray, Ary.Element == Element, Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var aryAIndex = lhs.startIndex
    var aryBIndex = rhs.startIndex
    while aryAIndex < lhs.endIndex {
        let aryAValue = lhs[aryAIndex]
        let aryBValue = rhs[aryBIndex]
        if !(aryAValue == aryBValue) { return false }
        aryAIndex = lhs.index(after: aryAIndex)
        aryBIndex = rhs.index(after: aryBIndex)
    }
    return true
}
public func ==<Ary, Element>(lhs: Array<Element>, rhs: Ary) -> Bool where Ary: SArray, Ary.Element == Element, Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    var aryAIndex = lhs.startIndex
    var aryBIndex = rhs.startIndex
    while aryAIndex < lhs.endIndex {
        let aryAValue = lhs[aryAIndex]
        let aryBValue = rhs[aryBIndex]
        if !(aryAValue == aryBValue) { return false }
        aryAIndex = lhs.index(after: aryAIndex)
        aryBIndex = rhs.index(after: aryBIndex)
    }
    return true
}

public func ~=<Ary, Element>(lhs: Ary, rhs: Array<Element>) -> Bool where Ary: SArray, Ary.Element == Element, Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    for v in lhs {
        if !rhs.contains(v) { return false }
    }
    return true
}

public func ~=<Ary, Element>(lhs: Array<Element>, rhs: Ary) -> Bool where Ary: SArray, Ary.Element == Element, Element: Equatable {
    guard lhs.count == rhs.count else { return false }
    guard lhs.count > 0 else { return true }
    for v in lhs {
        if !rhs.contains(v) { return false }
    }
    return true
}

// Mark: - Implementations
extension Array: SMutableArray, SAnyArray { }
