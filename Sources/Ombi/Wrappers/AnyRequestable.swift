//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/17/21.
//

import Foundation

/// # AnyRequestable
///
/// A type erased `Requestable` wrapper, with no other functional differences.
public struct AnyRequestable<RequestBody, ResponseBody, ResponseError>: Requestable where ResponseError: Error {
    
    // MARK: - Initializers
    
    /// Create an `AnyRequestable` from something that conforms to `Requestable`
    /// - Parameter requestable: The `Requestable` to type-erase
    public init<T>(_ requestable: T) where T: Requestable, T.RequestBody == RequestBody, T.ResponseBody == ResponseBody, T.ResponseError == ResponseError {
        pathClosure = { requestable.path }
        queryClosure = { requestable.query }
        methodClosure = { requestable.method }
        headersClosure = { requestable.headers }
        bodyClosure = { requestable.body }
        fallbackResponseClosure = { requestable.fallbackResponse }
        requestEncoderClosure = { requestable.requestEncoder }
        responseDecoderClosure = { requestable.responseDecoder }
        responseValidatorClosure = { requestable.responseValidator }
        timeoutIntervalClosure = { requestable.timeoutInterval }
    }
    
    // MARK: - Requestable
    
    public var path: String { pathClosure() }
    
    public var query: [String : String] { queryClosure() }
    
    public var method: RequestMethod { methodClosure() }
    
    public var headers: RequestHeaders { headersClosure() }
    
    public var body: RequestBody? { bodyClosure() }
    
    public var fallbackResponse: Response? { fallbackResponseClosure() }
    
    public var requestEncoder: BodyEncoder<RequestBody> { requestEncoderClosure() }
    
    public var responseDecoder: BodyDecoder<ResponseBody> { responseDecoderClosure() }
    
    public var responseValidator: ResponseValidator<ResponseBody, ResponseError> { responseValidatorClosure() }
    
    public var timeoutInterval: TimeInterval { timeoutIntervalClosure() }
    
    // MARK: - Private
    
    private let pathClosure: () -> String
    private let queryClosure: () -> [String : String]
    private let methodClosure: () -> RequestMethod
    private let headersClosure: () -> RequestHeaders
    private let bodyClosure: () -> RequestBody?
    private let fallbackResponseClosure: () -> Response?
    private let requestEncoderClosure: () -> BodyEncoder<RequestBody>
    private let responseDecoderClosure: () -> BodyDecoder<ResponseBody>
    private let responseValidatorClosure: () -> ResponseValidator<ResponseBody, ResponseError>
    private let timeoutIntervalClosure: () -> TimeInterval
}
