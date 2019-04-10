//
//  AnyArray.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-04-09.
//

import Foundation

public protocol SAnyArray {
    var elementType: Any.Type { get }
    var count: Int { get }
    var isEmpty: Bool { get }
    
    func item(at index: Int) -> Any
}
