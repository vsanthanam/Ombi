// Ombi
// AnyRequestable.swift
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

    public var query: [String: String] { queryClosure() }

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
    private let queryClosure: () -> [String: String]
    private let methodClosure: () -> RequestMethod
    private let headersClosure: () -> RequestHeaders
    private let bodyClosure: () -> RequestBody?
    private let fallbackResponseClosure: () -> Response?
    private let requestEncoderClosure: () -> BodyEncoder<RequestBody>
    private let responseDecoderClosure: () -> BodyDecoder<ResponseBody>
    private let responseValidatorClosure: () -> ResponseValidator<ResponseBody, ResponseError>
    private let timeoutIntervalClosure: () -> TimeInterval
}
