// Ombi
// BodyEncoder.swift
//
// MIT License
//
// Copyright (c) 2021 Varun Santhanam
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
//
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

/// A generic value type to encode request body content as `Data`
///
/// # Usage
///
/// You specilize the `Encoder` with the type you want to encoder, and pass in a closure to convert the type into `Data`
///
/// ```
/// let encoder = BodyEncoder<MyType> { body in
///     // return `Data?` or throw an error
/// }
/// ```
///
/// # Reusability
///
/// Typically, you will want to re-use body encoders for a given type.
///
/// The best way to do this is to declare a your encoder in a type-constrained extensions
///
/// ```
/// extension BodyEncoder where Body == MyType {
///     static var myEncoder: Self {
///         .init { body in
///             // Convert `MyType?` into `Data?` or throw an error
///         }
///     }
/// }
///
/// // You can now use this encoder with a `ComposableRequest`, or when creating type that conform to `Requestable`
///
/// let request = ComposableRequest<Any, MyType, Error>
///     .encode(with: .myEncoder)
///
/// struct MyRequest: Requestable {
///     var requestEncoder: BodyEncoder<MyType> {
///         .myEncoder
///     }
/// }
/// ```
///
/// Alternatively, if you want to create an encoder for a type you have control over, simply have that type conform to`AutomaticBodyEncoding`.
/// A `default` encoder is created for you automatically, and added by default to every `Requestable` or `ComposableRequest` type that has been specialized with your type as its `RequestBody`
///
/// ```
/// extension MyType: AutomaticBodyEncoding {
///     func asData() throws -> Data? {
///         // Return `Data?` or throw an error
///     }
/// }
///
/// // `default` is created for you automatically, and need not be added to `Requestable` or `ComposableRequest` instances.
/// let encoder = BodyEncoder<MyType>.default
/// ```
///
/// Ombi provides default body encoders for the following types:
///
/// - `String`
/// - `Data`
/// - `AnyJSON`
/// - `RequestParameters`
/// - Types that conform to`Encodable`
/// - Types that conform to `AutomaticBodyEncoding`
///
/// See similar types `BodyDecoder` and `ResponseValidator`
public struct BodyEncoder<Body> {

    // MARK: - Initializers

    /// Create a `BodyDecoder`
    /// - Parameter handler: The encoding closure
    init(_ handler: @escaping Handler) {
        encode = handler
    }

    // MARK: - API

    /// Closure used to encode `Body` to `Data`
    public typealias Handler = (Body?) throws -> Data?

    /// The handler that decodes `Body`
    public let encode: (Body?) throws -> Data?
}
