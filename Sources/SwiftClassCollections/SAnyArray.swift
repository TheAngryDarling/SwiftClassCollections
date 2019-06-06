//
//  AnyArray.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-04-09.
//

import Foundation

/// Protocol that defines any Array
public protocol SAnyArray {
    /// The Element Type constraint on this array
    var elementType: Any.Type { get }
    /// The number of elements in the array.
    var count: Int { get }
    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool { get }
    
    
    /// Accesses the element at the specified position.
    ///
    /// - Parameter index: The position of the element to access. index must be greater than or equal to Zero and less than count.
    /// - Returns: returns the elment at the specific index
    func item(at index: Int) -> Any
}
