// Ombi
// BodyDecoder+Ombi.swift
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

public extension BodyDecoder {

    /// A fatal decoder that will cause a runtime failure
    static var fatal: Self {
        .init { _ in
            assertionFailure("This response is contains body data but is missing a decoder!")
            return nil
        }
    }

}

public extension BodyDecoder where Body == String {

    /// Create a `String` body decoder with specified encoding
    /// - Parameter encoding: The encoding of the `String`
    init(encoding: String.Encoding = .utf8) {
        self = .init { data in
            guard let data = data else { return nil }
            return String(data: data, encoding: encoding)
        }
    }

    /// The default `String` body decoder
    static var `default`: Self {
        .init()
    }

}

public extension BodyDecoder where Body == Data {

    /// The default `Data` body decoder
    static var `default`: Self {
        .init { data in data }
    }

}

public extension BodyDecoder where Body == AnyJSON {

    /// Create a decoder for an `AnyJSON`
    /// - Parameter options: The reading options to use when deserializing the JSON
    init(options: JSONSerialization.ReadingOptions) {
        self = .init { data in
            guard let data = data else { return nil }
            return .init(try JSONSerialization.jsonObject(with: data, options: options))
        }
    }

    /// The default `AnyJSON` decoder
    static var `default`: Self {
        .init(options: [])
    }
}

public extension BodyDecoder where Body: Decodable {

    /// Create a decoder for a `Codable` using a `JSONDecoder`
    /// - Parameter decoder: The `JSONDecoder` to use for decoding
    /// - Returns: The decoder
    static func json(decoder: JSONDecoder = JSONDecoder()) -> Self {
        .init { data in
            guard let data = data else { return nil }
            return try decoder.decode(Body.self, from: data)
        }
    }

    /// The default `Codable` decoder
    static var `default`: Self {
        .json()
    }

}

public extension BodyDecoder where Body: AutomaticBodyDecoding {

    /// The default decoder for types that conform to `AutomaticBodyDecoding`
    static var `default`: Self {
        .init(Body.init)
    }
}

public extension BodyDecoder where Body == NoBody {
    static var `default`: Self {
        .init { _ in nil }
    }
}
