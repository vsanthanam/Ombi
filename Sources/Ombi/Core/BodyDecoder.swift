// Ombi
// BodyDecoder.swift
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

/// A generic value type to decode response body content from `Data`
///
/// # Usage
///
/// You specilize the `Decoder` with the type you want to decode, and pass in a closure to convert `Data` into the type:
///
/// ```
/// let decoder = BodyDecoder<MyType> { data in
///     // return `MyType?` or throw an error
/// }
/// ```
///
/// # Reusability
///
/// Typically, you will want to re-use body decoders for a given type.
///
/// The best way to do this is to declare a your decoder in a type-constrained extensions
///
/// ```
/// extension BodyDecoder where Body == MyType {
///     static var myDecoder: Self {
///         .init { data in
///             // Convert `Data?` into `MyType?` or throw an error
///         }
///     }
/// }
///
/// // You can now use this decoder with a `ComposableRequest`, or when creating type that conform to `Requestable`
///
/// let request = ComposableRequest<Any, MyType, Error>
///     .decode(with: .myDecoder)
///
/// struct MyRequest: Requestable {
///     var responseDecoder: BodyDecoder<MyType> {
///         .myDecoder
///     }
/// }
/// ```
///
/// Alternatively, if you want to create an decoder for a type you have control over, simply have that type conform to`AutomaticBodyDecoding`.
/// A `default` decoder is created for you automatically, and added by default to every `Requestable` or `ComposableRequest` type that has been specialized with your type as its `ResponseBody`
///
/// ```
/// extension MyType: AutomaticBodyDecoding {
///     init?(fromData: Data?) throws {
///        // Initialize `MyType`, return `nil`, or throw an error
///     }
/// }
///
/// // `default` is created for you automatically, and need not be added to `Requestable` or `ComposableRequest` instances.
/// let decoder = BodyDecoder<MyType>.default
/// ```
///
/// Ombi provides default body decoders for the following types:
///
/// - `String`
/// - `Data`
/// - `AnyJSON`
/// - Types that conform to`Decodable`
/// - Types that conform to `AutomaticBodyDecoding`
///
/// See similar types `BodyEncoder` and `ResponseValidator`
public struct BodyDecoder<Body> {

    // MARK: - Initializers

    /// Create a `BodyDecoder`
    /// - Parameter handler: The decoding closure
    init(_ handler: @escaping Handler) {
        decode = handler
    }

    // MARK: - API

    /// Closure used to decode `Body` from `Data`
    public typealias Handler = (Data?) throws -> Body?

    /// The handler that decodes `Data`
    public let decode: Handler
}
