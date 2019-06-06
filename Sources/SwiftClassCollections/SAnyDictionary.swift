//
//  AnyDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-04-09.
//

import Foundation

/// Protocol that defines any Dictionary
public protocol SAnyDictionary: SAnyArray {
    /// The Key Type constraint on this dictionary
    var keyType: Any.Type { get }
    /// The Value Type constraint on this dictionary
    var valueType: Any.Type { get }
    
    /// Accesses the value associated with the given key for reading.
    ///
    /// - Parameter key: The key to find in the dictionary.
    /// - Returns: The value associated with key if key is in the dictionary; otherwise, nil.
    func item(forKey key: Any) -> Any?
}
