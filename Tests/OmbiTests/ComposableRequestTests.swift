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

}
