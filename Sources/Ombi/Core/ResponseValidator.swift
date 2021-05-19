//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

/// A value type used to validate a `RequestResponse`
public struct ResponseValidator<Body, Error> where Error: Swift.Error {
    
    // MARK: - Initializers
    
    /// Create a `ResponseValidator`
    /// - Parameter handler: The closure used to validate
    public init(_ handler: @escaping Handler) {
        self.validate = handler
    }
    
    // MARK: - API
    
    /// Specialized `RequestResponse` that this validator can validate
    public typealias Response = RequestResponse<Body>
    
    /// Closure used to validate responses
    public typealias Handler = (Response) -> Result<Response, Error>
    
    /// The validation handler
    public let validate: Handler
    
}
