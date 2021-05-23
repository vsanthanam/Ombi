// Ombi
// ComposableRequestTests.swift
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

import CwlPreconditionTesting
import Foundation
@testable import Ombi
import XCTest

class ComposableRequestTests: XCTestCase {

    func test_pathMethod_updatesPath() {
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.path, "/")
        
        request = request.path("/path")
        
        XCTAssertEqual(request.path, "/path")
    }

    func test_pathClosure_updatesPath() {
        
        final class PathProvider {
            var executed = false
            func provide() -> String {
                executed = true
                return "/path"
            }
        }
        
        let provider = PathProvider()
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.path, "/")
        
        request = request.path { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.path, "/path")
        XCTAssertTrue(provider.executed)
    }

    func test_methodMethod_updatesPath() {
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.method, .get)
        
        request = request.method(.post)
        
        XCTAssertEqual(request.method, .post)
    }

    func test_methodClosure_updatesPath() {
        
        final class MethodProvider {
            var executed = false
            func provide() -> RequestMethod {
                executed = true
                return .post
            }
        }
        
        let provider = MethodProvider()
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.method, .get)
        
        request = request.method { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.method, .post)
        XCTAssertTrue(provider.executed)
    }

    func test_queryMethods_addQuery() {
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.query, [])
        
        request = request.query(URLQueryItem(name: "1", value: "1"))
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1")])
        
        request = request.query(URLQueryItem(name: "2", value: "2"))
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1"),
                                       URLQueryItem(name: "2", value: "2")])
        
        request = request.query(URLQueryItem(name: "3", value: "3"), URLQueryItem(name: "4", value: "4"))
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1"),
                                       URLQueryItem(name: "2", value: "2"),
                                       URLQueryItem(name: "3", value: "3"),
                                       URLQueryItem(name: "4", value: "4")])
    }
    
    func test_queryClosures_addQuery() {
        
        final class QueryProvider {
            var count = 0
            func provide() -> URLQueryItem {
                let item = URLQueryItem(name: (count+1).description, value: (count+1).description)
                count += 1
                return item
            }
        }
        
        
        var request = ComposableRequest<Any, Any, Error>()
        
        let provider = QueryProvider()
        
        XCTAssertEqual(request.query, [])
        
        request = request.query { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1")])
        XCTAssertEqual(provider.count, 1)

        request = request.query { [provider] in
            provider.provide()
        }

        XCTAssertEqual(request.query, [URLQueryItem(name: "2", value: "2"),
                                       URLQueryItem(name: "3", value: "3")])
        XCTAssertEqual(provider.count, 3)
    }
    
    func test_queriesMethod_replacesQuery() {
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.query, [])
        
        request = request.queries([URLQueryItem(name: "1", value: "1")])
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1")])
 
        request = request.queries([URLQueryItem(name: "2", value: "2")])
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "2", value: "2")])
    }
    
    func test_queriesClosure_replacesQuery() {
        var request = ComposableRequest<Any, Any, Error>()
        
        final class QueriesProvider {
            var count = 0
            func provide() -> [URLQueryItem] {
                let item = URLQueryItem(name: (count+1).description, value: (count+1).description)
                count += 1
                return [item]
            }
        }
        
        let provider = QueriesProvider()
        
        XCTAssertEqual(request.query, [])
        
        request = request.queries { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "1", value: "1")])
        XCTAssertEqual(provider.count, 1)
        
        request = request.queries { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.query, [URLQueryItem(name: "2", value: "2")])
        XCTAssertEqual(provider.count, 2)
    }
    
    func test_headerMethods_addHeader() {
        var request = ComposableRequest<Any, Any, Error>()
        
        XCTAssertEqual(request.headers, [:])
        
        request = request.header(key: "Header-1", value: "Value-1")
        
        XCTAssertEqual(request.headers, ["Header-1": "Value-1"])
        
        request = request.headers((key: "Header-2", value: "Value-2"), (key: "Header-3", value: "Value-3"))
        
        XCTAssertEqual(request.headers, ["Header-1": "Value-1",
                                         "Header-2": "Value-2",
                                         "Header-3": "Value-3"])
        
        request = request.headers([(key: "Header-4", value: "Value-4"), (key: "Header-5", value: "Value-5")])
        
        XCTAssertEqual(request.headers, ["Header-1": "Value-1",
                                         "Header-2": "Value-2",
                                         "Header-3": "Value-3",
                                         "Header-4": "Value-4",
                                         "Header-5": "Value-5"])
    }
    
    func test_headerClosure_addHeader() {
        var request = ComposableRequest<Any, Any, Error>()
        
        final class HeaderProvider {
            var count = 0
            func provide() -> (key: RequestHeaders.Key, value: RequestHeaders.Value) {
                let item = (key: RequestHeaders.Key("Header-\(count+1)"), value: RequestHeaders.Value.string("Value-\(count+1)"))
                count += 1
                return item
            }
        }
        
        let provider = HeaderProvider()
        
        XCTAssertEqual(request.headers, [:])
        
        request = request.header { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.headers, ["Header-1": "Value-1"])
        XCTAssertEqual(provider.count, 1)
        
        request = request.header { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.headers, ["Header-2": "Value-2",
                                         "Header-3": "Value-3"])
        XCTAssertEqual(provider.count, 3)
    }
    
    func test_bodyMethod_updatesBody() {
        var request = ComposableRequest<String, Any, Error>()
        
        XCTAssertNil(request.body)
        
        request = request.body("test")
        
        XCTAssertEqual(request.body, "test")
    }
    
    func test_bodyClosure_updatesBody() {
        final class BodyProvider {
            var executed = false
            func provide() -> String {
                executed = true
                return "test"
            }
        }
        
        let provider = BodyProvider()
        var request = ComposableRequest<String, Any, Error>()
        
        XCTAssertNil(request.body)
        
        request = request.body { [provider] in
            provider.provide()
        }
        
        XCTAssertEqual(request.body, "test")
        XCTAssertTrue(provider.executed)
    }
    
}
