//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

/// A generic value type to encode request body content as `Data`
public struct BodyEncoder<Body> {
    
    // MARK: - Initializers
    
    init(_ handler: @escaping Handler) {
        self.encode = handler
    }
    
    // MARK: - API
    
    public typealias Handler = (Body?) throws -> Data?
    
    public let encode: (Body?) throws -> Data?
}
