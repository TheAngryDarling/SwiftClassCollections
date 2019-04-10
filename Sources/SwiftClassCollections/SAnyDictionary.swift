//
//  AnyDictionary.swift
//  SwiftClassCollections
//
//  Created by Tyler Anger on 2019-04-09.
//

import Foundation

public protocol SAnyDictionary {
    var keyType: Any.Type { get }
    var valueType: Any.Type { get }
    
    var count: Int { get }
    var isEmpty: Bool { get }
    
    func item(forKey key: Any) -> Any?
}
