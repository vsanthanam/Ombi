//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public extension BodyDecoder {
    
    /// A fatal decoder that will cause a runtime failure
    static var `fatal`: Self {
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
