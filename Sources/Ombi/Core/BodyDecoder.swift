//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

/// A generic value type to decode response body content from `Data`
public struct BodyDecoder<Body> {
    
    // MARK: - Initializers
    
    /// Create a `BodyDecoder`
    /// - Parameter handler: The decoding closure
    init(_ handler: @escaping Handler) {
        self.decode = handler
    }
    
    // MARK: - API
    
    /// Closure used to decode `Body` from `Data`
    public typealias Handler = (Data?) throws -> Body?
    
    /// The handler that decodes `Data`
    public let decode: Handler
}
