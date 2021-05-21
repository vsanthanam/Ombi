// Ombi
// ResponseValidator.swift
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

/// A value type used to validate a `RequestResponse`
public struct ResponseValidator<Body, Error> where Error: Swift.Error {

    // MARK: - Initializers

    /// Create a `ResponseValidator`
    /// - Parameter handler: The closure used to validate
    public init(_ handler: @escaping Handler) {
        validate = handler
    }

    // MARK: - API

    /// Specialized `RequestResponse` that this validator can validate
    public typealias Response = RequestResponse<Body>

    /// Closure used to validate responses
    public typealias Handler = (Response) -> Result<Response, Error>

    /// The validation handler
    public let validate: Handler

}
