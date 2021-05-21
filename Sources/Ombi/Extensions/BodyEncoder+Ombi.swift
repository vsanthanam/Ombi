// Ombi
// BodyEncoder+Ombi.swift
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

public extension BodyEncoder {

    /// Fatal encoder that will cause a runtime failure
    static var fatal: Self {
        .init { _ in
            assertionFailure("This request is contains body data but is missing an encoder!")
            return nil
        }
    }

}

public extension BodyEncoder where Body == String {

    /// Create a `String` body encoder with a given encoding
    /// - Parameter encoding: The string encoding to use
    init(encoding: String.Encoding = .utf8) {
        self = .init { body in
            body?.data(using: encoding)
        }
    }

    /// The default `String` encoder
    static var `default`: Self {
        .init()
    }
}

public extension BodyEncoder where Body == Data {

    /// The default `data` encoder
    static var `default`: Self {
        .init { body in body }
    }

}

public extension BodyEncoder where Body == AnyJSON {

    /// Create an encoder for an `AnyJSON`
    /// - Parameter options: The writing options to use when serailzing the json
    init(options: JSONSerialization.WritingOptions) {
        self = .init { body in
            guard let body = body else { return nil }
            return try JSONSerialization.data(withJSONObject: body.obj, options: options)
        }
    }

    /// The default `AnyJSON` encoder
    static var `default`: Self {
        .init(options: [])
    }
}

public extension BodyEncoder where Body == RequestParameters {

    /// The default `RequestParameters` encoder
    static var `default`: Self {
        .init { body in
            guard let body = body else { return nil }
            return body.allParameters
                .reduce([String]()) { prev, parameter in
                    guard let encodedParamater = parameter.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                          let encodedValue = body[parameter]?.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        return prev
                    }
                    return prev + [encodedParamater + "=" + encodedValue]
                }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }

}

public extension BodyEncoder where Body: Encodable {

    /// Create an encoder for a `Codable` using a `JSONEncoder`
    /// - Parameter encoder: The `JSONEncoder` to use
    /// - Returns: The encoder
    static func json(encoder: JSONEncoder = JSONEncoder()) -> Self {
        .init { body in
            guard let body = body else { return nil }
            return try encoder.encode(body)
        }
    }

    /// The default `Codable` encoder
    static var `default`: Self {
        .json()
    }
}

public extension BodyEncoder where Body: AutomaticBodyEncoding {

    /// The default encoder for types that conform to `AutomaticBodyEncoding`
    static var `default`: Self {
        .init { body in
            try body?.asData()
        }
    }
}
