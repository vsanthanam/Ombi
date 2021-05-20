//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/8/21.
//

import Foundation
import Combine

/// A `Requestable` is an interfaces for types that express the details of an HTTP request
///
/// Types that conform to `Requestable` can be used as a paramater in `RequestManager`'s `makeRequest` method, to create an observable combine publisher.
/// `Requestable` is a generic procol that requires to you specify the request body, respose body, and error model.
///
/// Depending on what types you use to specialize the protocol, parts of the interface maybe already implemented for you.
/// See the documentation on each protocol requirement for more information.
public protocol Requestable {
    
    // MARK: - Generic Constraints
    
    /// The body type to be sent with this request
    associatedtype RequestBody
    
    /// The body type to expect from the response
    associatedtype ResponseBody
    
    /// Error generated by a response
    associatedtype ResponseError: Error
    
    // MARK: - Typealiases
    
    /// The specialized response to be returned by this request
    typealias Response = RequestResponse<ResponseBody>
    
    /// The specialized error to be generated by this request
    typealias Failure = RequestError<ResponseError>
    
    // MARK: - Requirements
    
    /// The path to request
    var path: String { get }
    
    /// The URL query to request
    var query: [String : String] { get }
    
    /// The HTTP method to use
    var method: RequestMethod { get }
    
    /// The HTTP headers to send
    var headers: RequestHeaders { get }
    
    /// The body to append to the request
    var body: RequestBody? { get }
    
    /// The response to use if the request fails
    /// A default fallback response of `nil` is implemented for you.
    var fallbackResponse: Response? { get }
    
    /// Encoder used to encode `RequestBody` into `Data`
    /// A default encoder is provided for you when `RequestBody` is one of the following:
    ///
    /// - `String`
    /// - `Data`
    /// - `AnyJSON`
    /// - `RequestParameters`
    /// - Types that conform to `Encodable`
    /// - Types that conform to `AutomaticBodyEncoding`
    var requestEncoder: BodyEncoder<RequestBody> { get }
    
    /// Decoder used to decode `Data` into `ResponseBody`
    /// A default decoder is provided for you when `ResponseBody` is one of the following:
    ///
    /// - `String`
    /// - `Data`
    /// - `AnyJSON`
    /// - Types that conform to `Decodable`
    /// - Types that conform to `AutomaticBodyDecoding`
    var responseDecoder: BodyDecoder<ResponseBody> { get }
    
    /// Validator used to check a fully constructoed `RequestResponse` for errors
    /// A default validator is implemented for you that automatically accepts all response as valid and makes no manipulations
    var responseValidator: ResponseValidator<ResponseBody, ResponseError> { get }
    
    /// Interval before the `RequestManager` times out.
    /// A default timeout interval of 120 seconds is implemented for you
    var timeoutInterval: TimeInterval { get }
}

/// A `Requestable` with `AnyJSON` body content
public protocol AnyJSONRequest: Requestable where ResponseError == HTTPError {}

/// A `Requestable` with `AnyJSON` body content and no validation
public protocol UnsafeAnyJSONRequest: Requestable where RequestBody == AnyJSON, ResponseBody == AnyJSON {}

/// A `Requestable` with `String` body content
public protocol StringRequest: UnsafeStringRequest where ResponseError == HTTPError {}
 
/// A `Requestable` with `String` body content and no validation
public protocol UnsafeStringRequest: Requestable where RequestBody == String, ResponseBody == String {}

/// A `Requestable` with `Data` body content
public protocol DataRequest: UnsafeStringRequest where ResponseError == HTTPError {}

/// A `Requestable` with `Data` body content and no validation
public protocol UnsafeDataRequest: Requestable where RequestBody == Data, ResponseBody == Data {}

/// A `Requestable` with `Codable` body content
public protocol CodableRequest: UnsafeStringRequest where ResponseError == HTTPError {}

/// A `Requestable` with `Codable` body content and no validation
public protocol UnsafeCodableRequest: Requestable where RequestBody: Encodable, ResponseBody: Decodable {}