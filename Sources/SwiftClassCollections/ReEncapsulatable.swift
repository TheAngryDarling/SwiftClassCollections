//
//  ReEncapsulatable.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-09-06.
//

import Foundation

/// Enum used to tell the reencapsulate function what dictionary type to use
public enum ReEncapsulateDictionary {
    case dictionary
    case classDictionary
    case arrayOrderedDictionary
}

//// Enum used to tell the reencapsulate function what array type to use
public enum ReEncapsulateArray {
    case array
    case classArray
}

/// Protocol used to identify what objects can be re-encapsulated
internal protocol ReEncapsulatableCollecton {
    /// Re-Encapsulate any ReEncapsulatableCollecton from one type to another
    ///
    /// - Parameters:
    ///   - dictionariesTo: what object to build dictionaries into
    ///   - arraysTo: what object to build arrays into
    /// - Returns: The newly created object for the given types
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary, arraysTo: ReEncapsulateArray) -> Any
    
    /// Re-Encapsulate any dictionaries from one type to another
    ///
    /// - Parameters:
    ///   - dictionariesTo: what object to build dictionaries into
    /// - Returns: The newly created object for the given types
    func _reencapsulate(dictionariesTo: ReEncapsulateDictionary) -> Any
    
    /// Re-Encapsulate any arrays from one type to another
    ///
    /// - Parameters:
    ///   - arraysTo: what object to build arrays into
    /// - Returns: The newly created object for the given types
    func _reencapsulate(arraysTo: ReEncapsulateArray) -> Any
    
}

/// Add a default method for easily switching to swift only structures
/*extension ReEncapsulatableCollecton {
    /// Provides a defualt to reencapsulate which converts object to standard swift arrays and dictionaries
    internal func reencapsulateToSwift() -> Any {
        return reencapsulate(dictionariesTo: .dictionary, arraysTo: .array)
    }
}*/

public protocol ReEncapsulatableArray: SArray {
    static var ReEncapsulateType: ReEncapsulateArray { get }
}

public protocol ReEncapsulatableDictionary: SDictionary {
    static var ReEncapsulateType: ReEncapsulateDictionary { get }
}


extension Array: ReEncapsulatableCollecton, ReEncapsulatableArray {
    public static var ReEncapsulateType: ReEncapsulateArray {
        return .array
    }
}

extension Dictionary: ReEncapsulatableCollecton, ReEncapsulatableDictionary {
   public static var ReEncapsulateType: ReEncapsulateDictionary {
        return .dictionary
    }
}
