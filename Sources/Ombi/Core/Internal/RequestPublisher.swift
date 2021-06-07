// Ombi
// RequestPublisher.swift
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

final class RequestPublisher<RequestBody, ResponseBody, ResponseError>: Publisher where ResponseError: Error {

    // MARK: - Initializers

    init<T>(session: URLSession,
            request: T,
            host: String,
            injectedHeaders: RequestHeaders,
            backupAuthentication: RequestAuthentication?,
            log: OSLog?) where T: Requestable, T.RequestBody == RequestBody, T.ResponseBody == ResponseBody, T.ResponseError == ResponseError {
        self.session = session
        self.request = .init(request)
        self.host = host
        self.injectedHeaders = injectedHeaders
        self.backupAuthentication = backupAuthentication
        self.log = log
    }

    // MARK: - Publisher

    func receive<S>(subscriber: S) where S: Subscriber, RequestError<ResponseError> == S.Failure, RequestResponse<ResponseBody> == S.Input {
        subscriber.receive(subscription: RequestSubscription<S, RequestBody, ResponseBody, ResponseError>(requestPublisher: self, downstream: subscriber))
    }

    typealias Output = RequestResponse<ResponseBody>

    typealias Failure = RequestError<ResponseError>

    // MARK: - Private

    fileprivate let session: URLSession
    fileprivate let request: AnyRequestable<RequestBody, ResponseBody, ResponseError>
    fileprivate let host: String
    fileprivate let injectedHeaders: RequestHeaders
    fileprivate let backupAuthentication: RequestAuthentication?
    fileprivate let log: OSLog?

}

private class RequestSubscription<Downstream, RequestBody, ResponseBody, ResponseError>: Subscription where Downstream: Subscriber, Downstream.Input == RequestPublisher<RequestBody, ResponseBody, ResponseError>.Output, Downstream.Failure == RequestPublisher<RequestBody, ResponseBody, ResponseError>.Failure, ResponseError: Error {

    // MARK: - Initializers

    init(requestPublisher: RequestPublisher<RequestBody, ResponseBody, ResponseError>, downstream: Downstream) {
        lock = .init()
        self.requestPublisher = requestPublisher
        self.downstream = downstream
        demand = .max(0)
    }

    // MARK: - Subscription

    func request(_ demand: Subscribers.Demand) {
        lock.lock()
        guard let requestPublisher = requestPublisher else {
            lock.unlock()
            return
        }

        guard var urlComponents = URLComponents(string: requestPublisher.host) else {
            self.demand += 1
            failWithMalformedComponents()
            return
        }

        urlComponents.path = "\(urlComponents.path)\(requestPublisher.request.path)"
        if !requestPublisher.request.query.isEmpty {
            urlComponents.queryItems = requestPublisher.request.query
        }

        guard let finalURL = urlComponents.url else {
            self.demand += 1
            failWithMalformedComponents()
            return
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = requestPublisher.request.method.rawValue
        if let body = requestPublisher.request.body {
            do {
                request.httpBody = try requestPublisher.request.requestEncoder.encode(body)
            } catch {
                self.demand += 1
                failWithMalformedComponents()
                return
            }
        }

        var headers = requestPublisher.request.headers
            .reduce([String: String]()) { prev, pair in
                let (key, value) = pair
                var next = prev
                next[key.description] = value.description
                return next
            }

        headers = requestPublisher.injectedHeaders
            .reduce(headers) { prev, pair in
                let (key, value) = pair
                var next = prev
                next[key.description] = value.description
                return next
            }

        if let authentication = requestPublisher.request.authentication ?? requestPublisher.backupAuthentication {
            headers[authentication.headerKey.description] = authentication.headerValue.description
        }

        request.allHTTPHeaderFields = headers

        request.timeoutInterval = requestPublisher.request.timeoutInterval

        if self.task == nil {
            let task = requestPublisher.session.dataTask(with: request,
                                                         completionHandler: handleResponse(data:response:error:))
            self.task = task
        }

        guard let log = requestPublisher.log else { return }
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
        if let body = requestPublisher.request.body {
            message.append("\nBody:\n\(String(describing: body))")
        }
        if let encodedBody = request.httpBody {
            message.append("\nEncoded Body:\n\(String(describing: encodedBody))")
        }
        os_log(.debug, log: log, "%@", message)

        self.demand += 1
        let task = self.task!
        lock.unlock()
        task.resume()
    }

    func cancel() {
        lock.lock()
        guard requestPublisher != nil else {
            lock.unlock()
            return
        }
        requestPublisher = nil
        downstream = nil
        demand = .max(0)
        let task = self.task
        self.task = nil
        lock.unlock()
        task?.cancel()
    }

    // MARK: - Private

    private let lock: Lock
    private var requestPublisher: RequestPublisher<RequestBody, ResponseBody, ResponseError>?
    private var downstream: Downstream?
    private var demand: Subscribers.Demand
    private var task: URLSessionDataTask!

    private func failWithMalformedComponents() {
        lock.lock()
        guard demand > 0,
              requestPublisher != nil,
              let downstream = downstream else {
            lock.unlock()
            return
        }

        requestPublisher = nil
        self.downstream = nil
        demand = .max(0)
        task = nil
        lock.unlock()
        downstream.receive(completion: .failure(.malformedRequest))
    }

    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        lock.lock()
        guard demand > 0,
              requestPublisher != nil,
              let downstream = downstream,
              let request = requestPublisher?.request else {
            lock.unlock()
            return
        }

        let log = requestPublisher?.log
        requestPublisher = nil
        self.downstream = nil

        demand = .max(0)
        task = nil
        lock.unlock()

        if let response = response,
           error == nil {
            do {
                let body = try request.responseDecoder.decode(data)
                let finalResponse: RequestResponse<ResponseBody>
                if let response = response as? HTTPURLResponse {
                    let headers = response.allHeaderFields.reduce(RequestHeaders()) { headers, pair in
                        let (field, value) = pair
                        var next = headers
                        next[.init(String(describing: field))] = .init(String(describing: value))
                        return next
                    }
                    finalResponse = .init(url: response.url, headers: headers, statusCode: response.statusCode, body: body)
                } else {
                    finalResponse = .init(url: response.url, headers: nil, statusCode: nil, body: body)
                }

                guard let log = log else { return }
                var message = ""
                if let urlString = response.url?.absoluteString {
                    message.append("Received Response from \(urlString)")
                } else {
                    message.append("Received Response")
                }
                if let code = finalResponse.statusCode {
                    message.append("\nStatus Code: \(code.description)")
                }
                if let headers = finalResponse.headers {
                    message.append("\nHeaders:\n\(headers.description)")
                }
                if let body = finalResponse.body {
                    message.append("\nBody:\n\(String(describing: body))")
                }
                os_log(.debug, log: log, "%@", message)

                _ = downstream.receive(finalResponse)
            } catch {
                downstream.receive(completion: .failure(.decodingError(error)))
            }
        } else {
            if let urlError = error as? URLError {
                if urlError.code == .timedOut {
                    downstream.receive(completion: .failure(.timedOut))
                }
                downstream.receive(completion: .failure(.urlSessionFailed(urlError)))
            } else {
                downstream.receive(completion: .failure(.unknownError))
            }
        }
    }
}

private final class Lock {
    private var isLocked: Bool = false

    func lock() {
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }
}
