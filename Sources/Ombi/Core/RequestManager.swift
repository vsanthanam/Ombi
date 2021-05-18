//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/8/21.
//

import Foundation
import Combine
import os.log

/// # RequestManager
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
/// ## Publisher
///
/// The publisher created by the `makeRequest` methods return a `RequestResponse` and  a `RequestError`.
/// See the documentation on both of these generic types for more information.
///
/// ## Custom Validation
///
/// ## Additional Headers
///
/// ## Default Headers
///
/// ## Logging
open class RequestManager {
    
    // MARK: - Initializers
    
    /// Create a `RequestManager`
    /// - Parameters:
    ///   - host: The host
    ///   - log: The log
    public init(host: String,
                log: OSLog? = .defaultRequestManagerLog) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7200
        configuration.timeoutIntervalForResource = 7200
        self.session = .init(configuration: configuration)
        self.host = host
        self.log = log
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
                T.Failure.timeoutSlaExceeded
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
                .validate(using: requestable)
            }
            .receive(on: scheduler)
            .handleEvents(receiveCompletion: { [log] completion in
                guard let log = log else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
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
    
    private let session: URLSession
    
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
            urlComponents.queryItems = requestable.query.reduce([URLQueryItem]()) { items, pair in
                let (key, value) = pair
                let item = URLQueryItem(name: key, value: value)
                return items + [item]
            }
        }
        guard let finalURL = urlComponents.url else {
            return InstantFailure(error: .malformedRequest)
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: finalURL)
        request.httpMethod = requestable.method.rawValue
        if let body = requestable.body {
            do {
                request.httpBody = try requestable.requestEncoder.handle(body)
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

        return session.dataTaskPublisher(for: request)
            .mapError { error in
                T.Failure.urlSessionFailed(error)
            }
            .tryMap { (data: Data, response: URLResponse) -> T.Response in
                do {
                    let body = try requestable.responseDecoder.handle(data)
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
            .validate(using: requestable)
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

        let ombiTag = "Ombi/\(Ombi.version)"

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

fileprivate extension Publisher {
    func validate<T>(using requestable: T) -> AnyPublisher<T.Response, T.Failure> where T: Requestable, T.Response == Output {
        tryMap { response in
            try requestable.responseValidator.handle(response).get()
        }
        .mapError { error in
            error.requestError()
        }
        .eraseToAnyPublisher()
    }
}
