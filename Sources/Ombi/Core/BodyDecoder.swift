//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

/// A generic value type to decode response body content from `Data`
///
/// # Usage
///
/// Typically, you will want to re-use body decoders for a given type.
///
/// The best way to do this is to declare a your decoder in a type-constrained extensions
///
/// ```
/// extension BodyDecoder where Body == MyType {
///     static var `default`: Self {
///         .init { body in
///             // Convert `MyType?` into `Data?` or throw an error
///         }
///     }
/// }
/// ```
///
/// Then, declare a type-constrained extension [Requestable](x-source-tag://Requestable)
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
///
/// See similar types `BodyEncoder` and `ResponseValidator`
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
