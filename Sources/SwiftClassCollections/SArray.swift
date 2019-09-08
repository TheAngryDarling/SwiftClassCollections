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

public extension SArray {
    
    var elementType: Any.Type { return Element.self }
    func item(at index: Int) -> Any {
        return self[index]
    }
}

internal extension SArray {
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary, arraysTo: ReEncapsulateArray) -> Any {
        var ary = Array<Element>()
        for e in self {
            guard let r = e as? ReEncapsulatableCollecton else {
                ary.append(e)
                continue
            }
            ary.append((r._reencapsulate(dictionariesTo: dictionariesTo, arraysTo: arraysTo)) as! Element)
        }
        switch arraysTo {
            case .array: return ary
            case .classArray: return SCArray<Element>(ary)
        }
    }
    
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary) -> Any {
        var ary = Array<Element>()
        for e in self {
            guard let r = e as? ReEncapsulatableCollecton else {
                ary.append(e)
                continue
            }
            ary.append((r._reencapsulate(dictionariesTo: dictionariesTo)) as! Element )
        }
        return type(of: self).init(ary)
    }
    
    func _reencapsulate(arraysTo: ReEncapsulateArray) -> Any {
        var ary = Array<Element>()
        for e in self {
            guard let r = e as? ReEncapsulatableCollecton else {
                ary.append(e)
                continue
            }
            ary.append((r._reencapsulate(arraysTo: arraysTo)) as! Element )
        }
        switch arraysTo {
            case .array: return ary
            case .classArray: return SCArray<Element>(ary)
        }
    }
}

public extension SArray where Element == Any {
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
    func reencapsulate<A, D>(dictionaries: D.Type, arrays: A.Type) -> A where D: ReEncapsulatableDictionary, A: ReEncapsulatableArray, A.Element == Element {
        return self.reencapsulate(dictionariesTo: D.ReEncapsulateType, arraysTo: A.ReEncapsulateType) as! A
    }
    
    /// Re-Encapsulate any child dictionaries to a difference container type
    ///
    /// - Parameters:
    ///   - dictionaries: what object type to build dictionaries into
    /// - Returns: The newly created object for the given types
    func reencapsulate<D>(dictionaries: D.Type) -> Self where D: ReEncapsulatableDictionary {
        return self.reencapsulate(dictionariesTo: D.ReEncapsulateType) as! Self
    }
    
    /// Re-Encapsulate the array and child arrays to a difference container type
    ///
    /// - Parameters:
    ///   - arrays: what object type to build arrays into
    /// - Returns: The newly created object for the given types
    func reencapsulate<A>(arrays: A.Type) -> A where A: ReEncapsulatableArray, A.Element == Element {
        return self.reencapsulate(arraysTo: A.ReEncapsulateType) as! A
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
