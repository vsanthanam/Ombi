// Ombi
// RequestManagerTests.swift
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
@testable import Ombi
import XCTest

final class RequestManagerTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    struct TestRequest<RequestBody, ResponseBody, ResponseError>: Requestable where ResponseError: Error {
        var path: String
        var query: [URLQueryItem]
        var method: RequestMethod
        var headers: RequestHeaders
        var body: RequestBody?
        var authentication: RequestAuthentication?
        var fallbackResponse: RequestResponse<ResponseBody>?
        var requestEncoder: BodyEncoder<RequestBody>
        var responseDecoder: BodyDecoder<ResponseBody>
        var responseValidator: ResponseValidator<ResponseBody, ResponseError>
        var timeoutInterval: TimeInterval
    }

    func test_constructsResponse_callsEncoder_callsDecoder_validatesResponse_returnsRsponse() {

        var completed = false
        var encoded = false
        var decoded = false
        var validated = false

        let requestEncoder = BodyEncoder<Data> { body in
            encoded = true
            return body
        }

        let responseDecoder = BodyDecoder<Data> { data in
            decoded = true
            return data
        }

        let responseValidator = ResponseValidator<Data, Error> { error in
            validated = true
            return .success(error)
        }
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: requestEncoder,
                                                     responseDecoder: responseDecoder,
                                                     responseValidator: responseValidator,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)

        publisherProvider.validateClosure = { request in
            XCTAssertEqual(request.url, URL(string: "https://app.myapi.com/"))
            XCTAssertEqual(request.url?.query, nil)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBody, "REQUEST".data(using: .utf8))
            XCTAssertEqual(request.timeoutInterval, 120.0)
        }

        let manager = RequestManager(host: "https://app.myapi.com", session: publisherProvider, log: nil)

        manager.makeRequest(request, on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                case .failure:
                    XCTFail()
                }
            } receiveValue: { response in
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(response.headers, [:])
                XCTAssertEqual(response.body, "RESPONSE".data(using: .utf8))
            }
            .store(in: &cancellables)
        let response = HTTPURLResponse(url: URL(string: "https://app.myapi.com/")!,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: [:])
        publisherProvider.sendResult(.success((data: "RESPONSE".data(using: .utf8)!, response: response!)))
        testScheduler.advance()
        XCTAssertTrue(completed)
        XCTAssertTrue(encoded)
        XCTAssertTrue(decoded)
        XCTAssertTrue(validated)
    }

    func test_usesRequestableFallback() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: RequestResponse<Data>(url: nil,
                                                                                             headers: [:],
                                                                                             statusCode: 200,
                                                                                             body: "FALLBACK1".data(using: .utf8)),
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        let fallback = RequestResponse<Data>(url: nil,
                                             headers: [:],
                                             statusCode: 201,
                                             body: "FALLBACK2".data(using: .utf8))
        manager.makeRequest(request, on: testScheduler, fallback: fallback)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                case .failure:
                    XCTFail()
                }
            } receiveValue: { response in
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(response.body, "FALLBACK1".data(using: .utf8))
            }
            .store(in: &cancellables)
        publisherProvider.sendResult(.failure(URLError(.cancelled)))
        testScheduler.advance()
        XCTAssertTrue(completed)
    }

    func test_usesManagerFallback() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        let fallback = RequestResponse<Data>(url: nil,
                                             headers: [:],
                                             statusCode: 201,
                                             body: "FALLBACK2".data(using: .utf8))
        manager.makeRequest(request, on: testScheduler, fallback: fallback)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                case .failure:
                    XCTFail()
                }
            } receiveValue: { response in
                XCTAssertEqual(response.statusCode, 201)
                XCTAssertEqual(response.body, "FALLBACK2".data(using: .utf8))
            }
            .store(in: &cancellables)
        publisherProvider.sendResult(.failure(URLError(.cancelled)))
        testScheduler.advance()
        XCTAssertTrue(completed)
    }

    func test_enforces_sla_noResponse() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler, delay: 10)
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.makeRequest(request, sla: .seconds(5), on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    guard case RequestError<Error>.slaExceeded = error else {
                        XCTFail()
                        return
                    }
                    completed = true
                }
            } receiveValue: { response in
                XCTFail()
            }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    func test_enforces_sla_lateResponse() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler, delay: 6)
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.makeRequest(request, sla: .seconds(5), on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    guard case RequestError<Error>.slaExceeded = error else {
                        XCTFail()
                        return
                    }
                    completed = true
                }
            } receiveValue: { response in
                XCTFail()
            }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        publisherProvider.sendResult(.success((data: Data(), response: URLResponse())))
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    func test_enforces_sla_lateError() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler, delay: 6)
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.makeRequest(request, sla: .seconds(5), on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail()
                case let .failure(error):
                    guard case RequestError<Error>.slaExceeded = error else {
                        XCTFail()
                        return
                    }
                    completed = true
                }
            } receiveValue: { response in
                XCTFail()
            }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        publisherProvider.sendResult(.failure(URLError(.badServerResponse)))
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    func test_usesRequestAuthentication() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     authentication: .token(type: .bearer, value: "request"),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)
        publisherProvider.validateClosure = { request in
            XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer request")
        }
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.requestAuthentication = .token(type: .bearer, value: "manager")
        manager.makeRequest(request, authentication: .token(type: .bearer, value: "param"), on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                default:
                    XCTFail()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        publisherProvider.sendResult(.success((Data(), URLResponse())))
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    func test_usesParameterAuthentication() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)
        publisherProvider.validateClosure = { request in
            XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer param")
        }
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.requestAuthentication = .token(type: .bearer, value: "manager")
        manager.makeRequest(request, authentication: .token(type: .bearer, value: "param"), on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                default:
                    XCTFail()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        publisherProvider.sendResult(.success((Data(), URLResponse())))
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    func test_usesManagerAuthentication() {
        var completed = false
        let testScheduler = DispatchQueue.ombiTest
        let request = TestRequest<Data, Data, Error>(path: "/",
                                                     query: [],
                                                     method: .post,
                                                     headers: [:],
                                                     body: "REQUEST".data(using: .utf8),
                                                     fallbackResponse: nil,
                                                     requestEncoder: .default,
                                                     responseDecoder: .default,
                                                     responseValidator: .unsafe,
                                                     timeoutInterval: 120.0)
        let publisherProvider = ResponsePublisherProvidingMock(scheduler: testScheduler)
        publisherProvider.validateClosure = { request in
            XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer manager")
        }
        let manager = RequestManager(host: "https://api.myapp.com",
                                     session: publisherProvider,
                                     log: nil)
        manager.requestAuthentication = .token(type: .bearer, value: "manager")
        manager.makeRequest(request, on: testScheduler)
            .sink { completion in
                switch completion {
                case .finished:
                    completed = true
                default:
                    XCTFail()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        XCTAssertFalse(completed)
        publisherProvider.sendResult(.success((Data(), URLResponse())))
        testScheduler.advance(by: .seconds(6))
        XCTAssertTrue(completed)
    }

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
    }
}

private class ResponsePublisherProvidingMock: ResponsePublisherProviding {

    init(scheduler: TestSchedulerOf<DispatchQueue>, delay: TimeInterval = 0.0) {
        self.scheduler = scheduler
        self.delay = delay
    }

    func publisher(for urlRequest: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        validateClosure(urlRequest)
        return subject
            .delay(for: .seconds(delay), scheduler: scheduler)
            .eraseToAnyPublisher()
    }

    var validateClosure: (URLRequest) -> Void = { _ in }

    func sendResult(_ result: Result<(data: Data, response: URLResponse), URLError>) {
        do {
            let response = try result.get()
            subject.send(response)
            subject.send(completion: .finished)
        } catch {
            subject.send(completion: .failure(error as! URLError))
        }
    }

    private let subject = PassthroughSubject<(data: Data, response: URLResponse), URLError>()
    private let delay: TimeInterval
    private let scheduler: TestSchedulerOf<DispatchQueue>
}
