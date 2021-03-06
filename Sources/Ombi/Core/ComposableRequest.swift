// Ombi
// ComposableRequest.swift
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

import Combine
import Foundation
import os.log

/// A `ComposableRequest` is a generic type used to execute HTTP requests without needing to create request-specific `Requestable` types.
///
/// Basic usage might look like this:
///
/// ```
/// cancellable = ComposableRequest<AnyJSON, AnyJSON, HTTPError>()
///     .path("/users")
///     .method(.post)
///     .headers([.contentType: .contentType(.json)])
///     .body(
///         [
///             "name": "morpheus",
///             "job": "leader"
///         ]
///     )
///     .send(on: "https://reqres.in/api")
///     .sink { result in
///         // handle completion
///     } receiveValue: { response in
///         // handle response
///     }
/// ```
/// You can specialize a `ComposableRequest` with body types, as well as an error model of your choosing.
/// If you use body types `String`, `Data`, `Codable`, `RequestParameters` or `AnyJSON`, default encoder and decoders are provided for you.
/// If you use an error type `HTTPError`, a response validator is used for you.
/// If you provide your own error model, rember to provide a validator, as the default validator automatically allows all responses to continue
public struct ComposableRequest<RequestBody, ResponseBody, ResponseError>: Requestable where ResponseError: Error {

    // MARK: - Initializers

    /// Create a `ComposableRequest`
    public init() {}

    // MARK: - API

    /// Set the request path
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .path("/posts/create")
    /// ```
    ///
    /// - Parameter path: The path
    /// - Returns: The request
    public func path(_ path: String) -> Self {
        self.path { path }
    }

    /// Set the request path
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .path {
    ///         // ... logic to determine the request path ...
    ///         return path
    ///     }
    /// ```
    ///
    /// - Parameter pathBuilder: The closure that builds the request path
    /// - Returns: The request
    public func path(_ pathBuilder: @escaping () -> String) -> Self {
        var copy = self
        copy.pathBuilder = pathBuilder
        return copy
    }

    /// Add a URL query
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .query(URLQueryItem(name: "key", value: "value"))
    /// ```
    ///
    /// - Parameters:
    ///   - query: The query parameter
    /// - Returns: The request
    public func query(_ query: URLQueryItem) -> Self {
        self.query { query }
    }

    /// Add a URL query
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .query {
    ///         // ... logic to determine the request query ...
    ///         return URLQueryItem(name: "key", value: "value")
    ///     }
    /// ```
    ///
    /// - Parameter queryBuilder: The closure that returns the URL query
    /// - Returns: The request
    public func query(_ queryBuilder: @escaping () -> URLQueryItem) -> Self {
        var copy = self
        copy.queryBuilders.append(queryBuilder)
        return copy
    }

    /// Add URL queries
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .query(URLQueryItem(name: "key1", value: "value1"),
    ///            URLQueryItem(name: "key2", value: "value2"))
    /// ```
    ///
    /// - Parameter queries: Query items
    /// - Returns: The request
    public func query(_ queries: URLQueryItem ...) -> Self {
        var copy = self
        for query in queries {
            copy.queryBuilders.append { query }
        }
        return copy
    }

    /// Replace the exsting URL queries with new ones
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .queries([URLQueryItem(name: "key1", value: "value1")
    ///               URLQueryItem(name: "key2", value: "value2")])
    /// ```
    ///
    /// - Parameter queries: The queries
    /// - Returns: The request
    public func queries(_ query: [URLQueryItem]) -> Self {
        queries { query }
    }

    /// Replace the existing URL queries with new ones
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .queries {
    ///         // ... logic to determine the request queries ...
    ///         return [URLQueryItem(name: "key1", value: "value1")
    ///                 URLQueryItem(name: "key2", value: "value2")]
    ///     }
    /// ```
    ///
    /// - Parameter queryBuilder: The closure that builds the queries
    /// - Returns: The request
    public func queries(_ queryBuilder: @escaping () -> [URLQueryItem]) -> Self {
        var copy = self
        copy.queryBuilder = queryBuilder
        copy.queryBuilders = []
        return copy
    }

    /// Set the HTTP method
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .method(.post)
    /// ```
    ///
    /// - Parameter method: The method to use
    /// - Returns: The request
    public func method(_ method: RequestMethod) -> Self {
        self.method { method }
    }

    /// Set the HTTP method
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .method {
    ///         ... logic to determine the request method ...
    ///         return .post
    ///     }
    /// ```
    ///
    /// - Parameter methodBuilder: Closure that builds the request method
    /// - Returns: The request
    public func method(_ methodBuilder: @escaping () -> RequestMethod) -> Self {
        var copy = self
        copy.methodBuilder = methodBuilder
        return copy
    }

    /// Add a header
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .header(key: "User-Agent", value: "MyUserAgentValue")
    /// ```
    ///
    /// - Parameters:
    ///   - key: The header field
    ///   - value: The header value
    /// - Returns: The request
    public func header(key: RequestHeaders.Key, value: RequestHeaders.Value?) -> Self {
        header { (key, value) }
    }

    /// Add a header
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .header {
    ///         /// ... logic to determine header ...
    ///         return (key: "User-Agent", value: "MyUserAgentValue")
    ///     }
    /// ```
    ///
    /// - Parameter headerBuilder: The closure that builds the header
    /// - Returns: The request
    public func header(_ headerBuilder: @escaping () -> (RequestHeaders.Key, RequestHeaders.Value?)) -> Self {
        var copy = self
        copy.headerBuilders.append(headerBuilder)
        return copy
    }

    /// Add headers
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .headers(pair1, pair2, pair3)
    /// ```
    ///
    /// - Parameter pairs: The pairs of headers to add
    /// - Returns: The request
    public func headers(_ pairs: (key: RequestHeaders.Key, value: RequestHeaders.Value) ...) -> Self {
        headers(pairs)
    }

    /// Add headers
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .headers([pair1, pair2, pair3])
    /// ```
    ///
    /// - Parameter pairs: The pairs of headers to add
    /// - Returns: The request
    public func headers(_ pairs: [(key: RequestHeaders.Key, value: RequestHeaders.Value)]) -> Self {
        var copy = self
        pairs.forEach { pair in
            copy.headerBuilders.append { pair }
        }
        return copy
    }

    /// Replace the existing headers with new ones
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .headers(["User-Agent" : "MyAgent",
    ///               "ContentType": "application/json"])
    /// ```
    ///
    /// - Parameter headers: The new headers
    /// - Returns: The request
    public func headers(_ headers: RequestHeaders) -> Self {
        self.headers { headers }
    }

    /// Replace the existing headers with new ones
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .headers {
    ///         /// ... logic to determine header ...
    ///         return ["User-Agent" : "MyAgent",
    ///                 "ContentType": "application/json"]
    ///     }
    /// ```
    ///
    /// - Parameter headersBuilder: The closure that builds the headers
    /// - Returns: The request
    public func headers(_ headersBuilder: @escaping () -> RequestHeaders) -> Self {
        var copy = self
        copy.headersBuilder = headersBuilder
        copy.headerBuilders = []
        return copy
    }

    /// Set the request body
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .body(myBody)
    /// ```
    ///
    /// - Parameter body: The body
    /// - Returns: The request
    public func body(_ body: RequestBody?) -> Self {
        self.body { body }
    }

    /// Set the request body
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .body {
    ///         // ... logic to determine body ...
    ///         return myBody
    ///     }
    /// ```
    ///
    /// - Parameter bodyBuilder: The closure that builds the body
    /// - Returns: The request
    public func body(_ bodyBuilder: @escaping () -> RequestBody?) -> Self {
        var copy = self
        copy.bodyBuilder = bodyBuilder
        return copy
    }

    /// Set the request authentication
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .authentication(.token(.bearer, "myToken"))
    /// ```
    /// - Parameter authentication: The authentication
    /// - Returns: The request
    public func authenticate(with authentication: RequestAuthentication?) -> Self {
        authenticate { authentication }
    }

    /// Set the request authentication
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>()
    ///     .authentication {
    ///         /// ... logic to determine authentication ...
    ///         return .token(.bearer, "myToken"))
    ///     }
    /// ```
    /// - Parameter authenticationBuilder: The closure that builds the authentication
    /// - Returns: The request
    public func authenticate(with authenticationBuilder: @escaping () -> RequestAuthentication?) -> Self {
        var copy = self
        copy.authenticationBuilder = authenticationBuilder
        return copy
    }

    /// Set the request authentication using basic username and password credentials
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>
    ///     .authentication(withUsername: "myUserName", password: "myPassword")
    /// ```
    /// - Parameters:
    ///   - username: Username
    ///   - password: Password
    /// - Returns: The request
    public func authenticate(withUsername username: String, password: String) -> Self {
        authenticate {
            .basic(username: username, password: password)
        }
    }

    /// Set the request authentication using an authorization token
    ///
    /// ```
    /// let request = ComposableRequest<Any, Any, Error>
    ///     .authentication(withToken: "myToken", type: .bearer)
    /// ```
    /// - Parameters:
    ///   - token: The token
    ///   - type: The type of token
    /// - Returns: the request
    public func authenticate(withToken token: String, type: RequestAuthentication.TokenType) -> Self {
        authenticate {
            .token(type: type, value: token)
        }
    }

    /// Add a fallback response to the request
    /// - Parameter fallbackResponse: The response to use if the request fails
    /// - Returns: The request
    public func fallbackResponse(_ fallbackResponse: RequestResponse<ResponseBody>?) -> Self {
        self.fallbackResponse { fallbackResponse }
    }

    /// Add a fallback response to the request
    /// - Parameter fallbackResponse: Closure that builds the fallback response, used if the request fails
    /// - Returns: The request
    public func fallbackResponse(_ fallbackResponseBuilder: @escaping () -> RequestResponse<ResponseBody>?) -> Self {
        var copy = self
        copy.fallbackResponseBuilder = fallbackResponseBuilder
        return copy
    }

    /// Add a request body encoder
    /// - Parameter handler: Closure used to transform `RequestBody` into `Data`
    /// - Returns: The request
    public func encodeBody(with handler: @escaping (RequestBody?) throws -> Data?) -> Self {
        encodeBody(with: .init(handler))
    }

    /// Add a request body encoder
    /// - Parameter encoder: Encoder used to handle request
    /// - Returns: The request
    public func encodeBody(with encoder: BodyEncoder<RequestBody>) -> Self {
        var copy = self
        copy.customRequestEncoder = encoder
        return copy
    }

    /// Add a response body decoder
    /// - Parameter handler: Closure used to transform `ResponseBody` into `Data`
    /// - Returns: The request
    public func decodeBody(with handler: @escaping (Data?) throws -> ResponseBody?) -> Self {
        decodeBody(with: .init(handler))
    }

    /// Add a response body decoder
    /// - Parameter decoder: Decoder used to handle response
    /// - Returns: The request
    public func decodeBody(with decoder: BodyDecoder<ResponseBody>) -> Self {
        var copy = self
        copy.customResponseDecoder = decoder
        return copy
    }

    /// Add a response validator
    /// - Parameter handler: Closure used to validate a `Response`
    /// - Returns: The request
    public func validateResponse(with handler: @escaping (Response) -> Result<Response, ResponseError>) -> Self {
        validateResponse(with: .init(handler))
    }

    /// Add a response validator
    /// - Parameter responseValidator: Response validator
    /// - Returns: The request
    public func validateResponse(with responseValidator: ResponseValidator<ResponseBody, ResponseError>) -> Self {
        var copy = self
        copy.customResponseValidator = responseValidator
        return copy
    }

    /// Add a timeout interval
    /// - Parameter interval: The interval for requests to timeout
    /// - Returns: The request
    public func timeoutInterval(_ interval: TimeInterval) -> Self {
        timeoutInterval { interval }
    }

    /// Add a timeout interval
    /// - Parameter intervalBuilder: Closure to build the timeout interval
    /// - Returns: The request
    public func timeoutInterval(_ intervalBuilder: @escaping () -> TimeInterval) -> Self {
        var copy = self
        copy.timeoutIntervalBuilder = intervalBuilder
        return copy
    }

    /// Send this request on the main thread
    /// - Parameters:
    ///   - host: The host
    ///   - retries: The number of retries
    ///   - sla: The SLA to use before timing out
    /// - Returns: A publisher to observe request responses
    public func send(on host: String,
                     retries: Int = 0,
                     sla: TimeInterval = 120) -> AnyPublisher<Response, Failure> {
        send(on: host,
             retries: retries,
             sla: .seconds(sla),
             using: DispatchQueue.global())
    }

    /// Send this request on the main thread
    /// - Parameters:
    ///   - host: The host
    ///   - retries: The number of retries
    ///   - sla: The SLA to use before timing out
    ///   - log: The log used to write network request info.
    /// - Returns: A publisher to observe request responses
    public func send(on host: String,
                     retries: Int = 0,
                     sla: TimeInterval = 120,
                     log: OSLog) -> AnyPublisher<Response, Failure> {
        send(on: host,
             retries: retries,
             sla: .seconds(sla),
             using: DispatchQueue.global(),
             log: log)
    }

    /// Send this request
    /// - Parameters:
    ///   - host: The host
    ///   - retries: The number of retries
    ///   - sla: The SLA to use before timing out
    ///   - scheduler: The scheduler to use
    /// - Returns: A publisher to observe request responses
    public func send<S>(on host: String,
                        retries: Int = 0,
                        sla: S.SchedulerTimeType.Stride = .seconds(120),
                        using scheduler: S) -> AnyPublisher<Response, Failure> where S: Scheduler {
        let manager = RequestManager(host: host)
        return manager.makeRequest(self,
                                   retries: retries,
                                   sla: sla,
                                   on: scheduler)
    }

    /// Send this request
    /// - Parameters:
    ///   - host: The host
    ///   - retries: The number of retries
    ///   - sla: The SLA to use before timing out
    ///   - scheduler: The scheduler to use
    ///   - log: The log used to write network request info.
    /// - Returns: A publisher to observe request responses
    public func send<S>(on host: String,
                        retries: Int = 0,
                        sla: S.SchedulerTimeType.Stride = .seconds(120),
                        using scheduler: S,
                        log: OSLog) -> AnyPublisher<Response, Failure> where S: Scheduler {
        let manager = RequestManager(host: host, log: log)
        return manager.makeRequest(self,
                                   retries: retries,
                                   sla: sla,
                                   on: scheduler)
    }

    // MARK: - Requestable

    public var path: String {
        pathBuilder()
    }

    public var query: [URLQueryItem] {
        var base = queryBuilder()
        for builder in queryBuilders {
            base.append(builder())
        }
        return base
    }

    public var method: RequestMethod {
        methodBuilder()
    }

    public var headers: RequestHeaders {
        var base = headersBuilder()
        for builder in headerBuilders {
            let (key, value) = builder()
            base[key] = value
        }
        return base
    }

    public var body: RequestBody? {
        bodyBuilder()
    }

    public var authentication: RequestAuthentication? {
        authenticationBuilder()
    }

    public var fallbackResponse: RequestResponse<ResponseBody>? {
        fallbackResponseBuilder()
    }

    public var requestEncoder: BodyEncoder<RequestBody> {
        if let customRequestEncoder = customRequestEncoder {
            return customRequestEncoder
        } else if RequestBody.self is String.Type {
            return unsafeBitCast(BodyEncoder<String>.default, to: BodyEncoder<RequestBody>.self)
        } else if RequestBody.self is Data.Type {
            return unsafeBitCast(BodyEncoder<Data>.default, to: BodyEncoder<RequestBody>.self)
        } else if RequestBody.self is AnyJSON.Type {
            return unsafeBitCast(BodyEncoder<AnyJSON>.default, to: BodyEncoder<RequestBody>.self)
        } else if RequestBody.self is RequestParameters.Type {
            return unsafeBitCast(BodyEncoder<RequestParameters>.default, to: BodyEncoder<RequestBody>.self)
        } else if RequestBody.self is Encodable.Type {
            return .init { body in
                guard let body = (body as? Encodable) else { return nil }
                return try body.encoded()
            }
        } else if RequestBody.self is AutomaticBodyEncoding.Type {
            return .init { body in
                guard let body = (body as? AutomaticBodyEncoding) else { return nil }
                return try body.asData()
            }
        } else if RequestBody.self is NoBody.Type {
            return unsafeBitCast(BodyEncoder<NoBody>.default, to: BodyEncoder<RequestBody>.self)
        } else {
            return BodyEncoder<RequestBody>.fatal
        }
    }

    public var responseDecoder: BodyDecoder<ResponseBody> {
        if let customResponseDecoder = customResponseDecoder {
            return customResponseDecoder
        } else if ResponseBody.self is String.Type {
            return unsafeBitCast(BodyDecoder<String>.default, to: BodyDecoder<ResponseBody>.self)
        } else if ResponseBody.self is Data.Type {
            return unsafeBitCast(BodyDecoder<Data>.default, to: BodyDecoder<ResponseBody>.self)
        } else if ResponseBody.self is AnyJSON.Type {
            return unsafeBitCast(BodyDecoder<AnyJSON>.default, to: BodyDecoder<ResponseBody>.self)
        } else if let desiredType = ResponseBody.self as? Decodable.Type {
            return .init { data in
                guard let data = data else { return nil }
                let decoded = try desiredType.decoded(from: data)
                return decoded as? ResponseBody
            }
        } else if let desiredType = ResponseBody.self as? AutomaticBodyDecoding.Type {
            return .init { data in
                guard let data = data else { return nil }
                let decoded = try desiredType.init(fromData: data)
                return decoded as? ResponseBody
            }
        } else if ResponseBody.self is NoBody.Type {
            return unsafeBitCast(BodyDecoder<NoBody>.default, to: BodyDecoder<ResponseBody>.self)
        } else {
            return BodyDecoder<ResponseBody>.fatal
        }
    }

    public var responseValidator: ResponseValidator<ResponseBody, ResponseError> {
        if let customResponseValidator = customResponseValidator {
            return customResponseValidator
        } else if ResponseError.self is HTTPError.Type {
            return unsafeBitCast(ResponseValidator<ResponseBody, HTTPError>.default, to: ResponseValidator<ResponseBody, ResponseError>.self)
        } else if ResponseError.self is NoError.Type {
            return unsafeBitCast(ResponseValidator<ResponseBody, NoError>.default, to: ResponseValidator<ResponseBody, ResponseError>.self)
        } else {
            return .unsafe
        }
    }

    public var timeoutInterval: TimeInterval {
        timeoutIntervalBuilder()
    }

    // MARK: - Private

    private var pathBuilder: () -> String = { "/" }
    private var queryBuilders: [() -> (URLQueryItem)] = []
    private var queryBuilder: () -> [URLQueryItem] = { [] }
    private var methodBuilder: () -> RequestMethod = { .get }
    private var headerBuilders: [() -> (RequestHeaders.Key, RequestHeaders.Value?)] = []
    private var headersBuilder: () -> RequestHeaders = { [:] }
    private var bodyBuilder: () -> RequestBody? = { nil }
    private var authenticationBuilder: () -> RequestAuthentication? = { nil }
    private var fallbackResponseBuilder: () -> RequestResponse<ResponseBody>? = { nil }
    private var customRequestEncoder: BodyEncoder<RequestBody>?
    private var customResponseDecoder: BodyDecoder<ResponseBody>?
    private var customResponseValidator: ResponseValidator<ResponseBody, ResponseError>?
    private var timeoutIntervalBuilder: () -> TimeInterval = { 120.0 }

}
