// Ombi
// ResponseValidator+Ombi.swift
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

public extension ResponseValidator where Error == HTTPError {

    /// The default response validator for `HTTPError` types, which returns an error based on the status code
    static var `default`: Self {
        .init { response in
            guard let code = response.statusCode else {
                return .success(response)
            }
            if let error = Error(code) {
                return .failure(error)
            }
            return .success(response)
        }
    }

}

public extension ResponseValidator {

    /// An unsafe response validator, which never returns an error, regardless of the content of the response
    static var unsafe: Self {
        .init { .success($0) }
    }

}

public extension ResponseValidator where Error == NoError {
    static var `default`: Self {
        .init { .success($0) }
    }
}
