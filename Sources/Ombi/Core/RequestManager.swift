// Ombi
// RequestManager.swift
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

/// ## Introduction
///
/// An object used to execute `Requestable(s)`
///
/// Basic usage might look like this:
///
/// ```
/// struct MyRequest: Requestable {
///     ...
/// }
///
/// let manager = RequestManager(host: "https://api.myapp.com")
/// let request = MyRequest()
/// let cancellable = manager.makeRequest(request,
///                                       retries: 3,
///                                       sla: .seconds(120),
///                                       on: DispathQueue.main)
///     .replaceError(with: .empty)
///     .map(\.body)
///     .sink { responseBody in
///         ...
///     }
/// ```
///
/// ### Publisher
///
/// The publisher created by the `makeRequest` methods return a `RequestResponse` and  a `RequestError`.
/// See the documentation on both of these generic types for more information.
///
/// ### Request Lifecycle & Error Handling
///
/// The request lifecycle creates many different points of failure, and provides users with a robust error model to determin what went wrong and where
///
/// 1. The request is created. Possible failures inlcude an invalid URL, or a failure to encode the `RequestBody`, if one is present
/// 2. The request is excecuted. Possible failures include a broken network connection, a missing host, or a timeout.
/// 3. The request is parsed. The only possible failure here would be an attempt to decode the response data
/// 4. The request is validated. The provided `ResponseValidator` examines the response's headers, status code, and body and choose to manipulate it or throw and error. See the "Validation step below for more information.
///
/// When the manager encounters any of the errors describer above, you can choose to retry to request. The number of retries is specified as a paramater in the `makeRequest<T, S>(_:retries:sla:on:fallback:)` method. You can also specify an SLA by which all retries must complete, and an optional fallback response to use. The request object itself can also contain a fallback response.
///
/// ### Additional Headers
///
/// In addition to the headers specified in the `Requestable`, you can have the manager inject its own headers on every request it makes. This can be useful for handling things like authentication.
///
/// ```
/// let manager = RequestManager(host: "https://www.apple.com")
/// manager.additionalHeaders = [.authorization, .authorization(username: "myusername", password: "mypassword"]
/// // these headers will be injected into every request
/// ```
///
/// ### Default Headers
///
/// `RequestManager` automatically injects `User-Agent`, `Accept-Encoding`, and `Accept-Language` headers into every request it makes by default.
/// You can disable this behavior by setting the `shouldInjectDefaultHeaders` property to `false`
///
/// ### Logging
///
/// `RequestManager` support logging via [Apple Unified Logging](https://developer.apple.com/documentation/oslog)
/// To enable this, use one of the initializers that accept a log subsystem or an `OSLog` instance
open class RequestManager {

    // MARK: - Initializers

    /// Create a `RequestManager`
    /// - Parameter host: The host to send requests
    public convenience init(host: String) {
        self.init(host, log: nil)
    }

    /// Create a `RequestManager` using the default log
    /// - Parameters:
    ///   - host: The host to send requests
    ///   - subsystem: The subsystem to send logs
    public convenience init(host: String, subsystem: String) {
        self.init(host, log: OSLog(subsystem: subsystem, category: "OmbiRequestManager"))
    }

    /// Create a `RequestManager` using a custom log
    /// - Parameters:
    ///   - host: The host to send requests
    ///   - log: The log
    public convenience init(host: String, log: OSLog) {
        self.init(host, log: log)
    }

    // MARK: - API

    /// The host
    public let host: String

    /// The log to use
    public let log: OSLog?

    /// Headers to add to every request
    open var additionalHeaders: RequestHeaders = [:]

    /// Whether or not to inject Ombi's default headers
    open var shouldInjectDefaultHeaders: Bool = true

    /// Make a request
    /// - Parameters:
    ///   - requestable: The `Requestable` to request
    ///   - retries: The number of retries
    ///   - sla: The SLA execute all retries before timing out
    ///   - scheduler: The scheduler to use
    /// - Returns: A `Publisher` to observe request responses or errors
    public final func makeRequest<T, S>(_ requestable: T,
                                        retries: Int = 0,
                                        sla: S.SchedulerTimeType.Stride = .seconds(180.0),
                                        on scheduler: S,
                                        fallback: T.Response? = nil) -> AnyPublisher<T.Response, T.Failure> where T: Requestable, S: Scheduler {
        publisher(for: requestable,
                  scheduler: scheduler)
            .retry(retries)
            .timeout(sla,
                     scheduler: scheduler,
                     options: nil) {
                T.Failure.slaExceeded
            }
            .catch() { [log] error in
                Future<T.Response, T.Failure> { promise in
                    if let response = requestable.fallbackResponse ?? fallback {
                        if let log = log {
                            os_log(.error, log: log, "Request Failed: %@ -- Using Fallback Response", error.localizedDescription)
                        }
                        return promise(.success(response))
                    } else {
                        return promise(.failure(error))
                    }
                }
                .validate(using: requestable.responseValidator)
            }
            .receive(on: scheduler)
            .handleEvents(receiveCompletion: { [log] completion in
                guard let log = log else { return }
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    os_log(.error, log: log, "Request Failed: %@", error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }

    /// Make a request
    /// - Parameters:
    ///   - requestable: The `Requestable` to request
    ///   - retries: The number of retries
    ///   - sla: The SLA to use before timing out
    /// - Returns: A `Publisher` to observe request responses or errors
    public final func makeRequest<T>(_ requestable: T,
                                     retries: Int = 0,
                                     sla: TimeInterval = 180.0,
                                     fallback: T.Response? = nil) -> AnyPublisher<T.Response, T.Failure> where T: Requestable {
        makeRequest(requestable,
                    retries: retries,
                    sla: .seconds(sla),
                    on: DispatchQueue.global(),
                    fallback: fallback)
    }

    // MARK: - Private

    init(host: String,
         session: ResponsePublisherProviding,
         log: OSLog?) {
        self.host = host
        self.session = session
        self.log = log
    }

    private convenience init(_ host: String,
                             log: OSLog?) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7200
        configuration.timeoutIntervalForResource = 7200
        let session = URLSession(configuration: configuration)
        self.init(host: host, session: session, log: log)
    }

    private let session: ResponsePublisherProviding

    private var defaultHeaders: RequestHeaders {
        guard shouldInjectDefaultHeaders else {
            return [:]
        }
        return [.userAgent: RequestManager.defaultUserAgent,
                .acceptEncoding: "br;q=1.0, gzip;q=0.8, deflate;q=0.6",
                .acceptLanguage: RequestManager.defaultAcceptLanguage]
    }

    private func publisher<T, S>(for requestable: T, scheduler: S) -> AnyPublisher<T.Response, T.Failure> where T: Requestable, S: Scheduler {
        typealias InstantFailure = Fail<T.Response, T.Failure>
        guard var urlComponents = URLComponents(string: host) else {
            return InstantFailure(error: .malformedRequest)
                .eraseToAnyPublisher()
        }
        urlComponents.path = "\(urlComponents.path)\(requestable.path)"
        if !requestable.query.isEmpty {
            urlComponents.queryItems = requestable.query
        }
        guard let finalURL = urlComponents.url else {
            return InstantFailure(error: .malformedRequest)
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = requestable.method.rawValue
        if let body = requestable.body {
            do {
                request.httpBody = try requestable.requestEncoder.encode(body)
            } catch {
                return InstantFailure(error: .malformedRequest)
                    .eraseToAnyPublisher()
            }
        }
        var dict = defaultHeaders
            .reduce([String: String]()) { prev, pair in
                let (key, value) = pair
                var next = prev
                next[key.description] = value.description
                return next
            }

        dict = requestable.headers
            .reduce(dict) { prev, pair in
                let (key, value) = pair
                var next = prev
                next[key.description] = value.description
                return next
            }

        request.allHTTPHeaderFields = additionalHeaders
            .reduce(dict) { prev, pair in
                let (key, value) = pair
                var next = prev
                next[key.description] = value.description
                return next
            }
        request.timeoutInterval = requestable.timeoutInterval

        return session.publisher(for: request)
            .mapError { error -> T.Failure in
                if error.code == URLError.timedOut {
                    return T.Failure.timedOut
                }
                return T.Failure.urlSessionFailed(error)
            }
            .tryMap { (data: Data, response: URLResponse) -> T.Response in
                do {
                    let body = try requestable.responseDecoder.decode(data)
                    if let response = response as? HTTPURLResponse {
                        let headers = response.allHeaderFields.reduce(RequestHeaders()) { headers, pair in
                            let (field, value) = pair
                            var next = headers
                            next[.init(String(describing: field))] = .init(String(describing: value))
                            return next
                        }
                        return .init(url: response.url, headers: headers, statusCode: response.statusCode, body: body)
                    }
                    return .init(url: response.url, headers: nil, statusCode: nil, body: body)
                } catch {
                    throw T.Failure.decodingError(error)
                }
            }
            .handleEvents(receiveOutput: { [log] response in
                guard let log = log else { return }
                var message = ""
                if let urlString = response.url?.absoluteString {
                    message.append("Received Response from \(urlString)")
                } else {
                    message.append("Received Response")
                }
                if let code = response.statusCode {
                    message.append("\nStatus Code: \(code.description)")
                }
                if let headers = response.headers {
                    message.append("\nHeaders:\n\(headers.description)")
                }
                if let body = response.body {
                    message.append("\nBody:\n\(String(describing: body))")
                }
                os_log(.debug, log: log, "%@", message)
            })
            .validate(using: requestable.responseValidator)
            .handleEvents(receiveSubscription: { [log] _ in
                guard let log = log else { return }
                var message = "Making Request"
                if let urlString = request.url?.absoluteString {
                    message.append("\nURL: \(urlString)")
                }
                if let method = request.requestMethod {
                    message.append("\nMethod: \(method)")
                }
                if let headers = request.allHTTPHeaderFields {
                    message.append("\nHeaders:\n\(headers.description)")
                }
                if let body = requestable.body {
                    message.append("\nBody:\n\(String(describing: body))")
                }
                if let encodedBody = request.httpBody {
                    message.append("\nEncoded Body:\n\(String(describing: encodedBody))")
                }
                os_log(.debug, log: log, "%@", message)
            })
            .eraseToAnyPublisher()
    }

    private static var defaultUserAgent: RequestHeaders.Value {
        let bundle = Bundle.main.infoDictionary
        let host = (bundle?[kCFBundleExecutableKey as String] as? String) ??
            (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
            "Unknown"
        let identifier = bundle?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let version = bundle?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = bundle?[kCFBundleVersionKey as String] as? String ?? "Unknown"

        let os: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            let osName: String = {
                #if os(iOS)
                    #if targetEnvironment(macCatalyst)
                        return "macOS(Catalyst)"
                    #else
                        return "iOS"
                    #endif
                #elseif os(watchOS)
                    return "watchOS"
                #elseif os(tvOS)
                    return "tvOS"
                #elseif os(macOS)
                    return "macOS"
                #elseif os(Linux)
                    return "Linux"
                #elseif os(Windows)
                    return "Windows"
                #else
                    return "Unknown"
                #endif
            }()

            return "\(osName) \(versionString)"
        }()

        let ombiTag = "Ombi/1.0.3"

        return .init(host + "/" + version + " (" + identifier + ";" + "build:" + build + ";" + " " + os + ")" + " " + ombiTag)
    }

    private static var defaultAcceptLanguage: RequestHeaders.Value {
        let str = Locale.preferredLanguages
            .prefix(6)
            .enumerated()
            .map { index, encoding in
                let quality = 1.0 - (Double(index) * 0.1)
                return "\(encoding);q=\(quality)"
            }
            .joined(separator: ", ")
        return .init(str)
    }
}

private extension Publisher {
    func validate<T, E>(using validator: ResponseValidator<T, E>) -> AnyPublisher<RequestResponse<T>, RequestError<E>> where Output == RequestResponse<T> {
        tryMap { response in
            try validator.validate(response).get()
        }
        .mapError { error in
            error.requestError()
        }
        .eraseToAnyPublisher()
    }
}
