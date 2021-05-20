//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

/// A generic value type to encode request body content as `Data`
///
/// # Usage
///
/// Typically, you will want to re-use body encoders for a given type.
///
/// The best way to do this is to declare a your encoder in a type-constrained extensions
///
/// ```
/// extension BodyEncoder where Body == MyType {
///     static var `default`: Self {
///         .init { body in
///             // Convert `MyType?` into `Data?` or throw an error
///         }
///     }
/// }
/// ```
///
/// Then, declare a type-constrained extension `Requestable`
///
/// ```
/// extension Requestable where RequestBody == MyType {
///     var requestEncoder: BodyEncoder<RequestBody> {
///         return .default
///     }
/// }
/// ```
///
/// Ombi provides default body encoders for the following types:
///
/// - `String`
/// - `Data`
/// - `AnyJSON`
/// - Models that conform to`Encodable`
/// - `RequestParameters`
///
/// See similar types `BodyDecoder` and `ResponseValidator`
public struct BodyEncoder<Body> {
    
    // MARK: - Initializers
    
    /// Create a `BodyDecoder`
    /// - Parameter handler: The encoding closure
    init(_ handler: @escaping Handler) {
        self.encode = handler
    }
    
    // MARK: - API
    
    /// Closure used to encode `Body` to `Data`
    public typealias Handler = (Body?) throws -> Data?
    
    /// The handler that decodes `Body`
    public let encode: (Body?) throws -> Data?
}
