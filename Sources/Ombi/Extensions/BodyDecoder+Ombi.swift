//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public extension BodyDecoder {
    
    static var `fatal`: Self {
        .init { _ in fatalError() }
    }
    
}

public extension BodyDecoder where Body == String {
    
    init(encoding: String.Encoding) {
        self = .init { data in
            guard let data = data else { return nil }
            return String(data: data, encoding: encoding)
        }
    }
    
    static var `default`: Self {
        .init(encoding: .utf8)
    }
    
}

public extension BodyDecoder where Body == Data {
    
    static var `default`: Self {
        .init { data in data }
    }
    
}

public extension BodyDecoder where Body == AnyJSON {
    
    init(options: JSONSerialization.ReadingOptions) {
        self = .init { data in
            guard let data = data else { return nil }
            return .init(try JSONSerialization.jsonObject(with: data, options: options))
        }
    }
    
    static var `default`: Self {
        .init(options: [])
    }
}

public extension BodyDecoder where Body: Decodable {
    
    static func json(decoder: JSONDecoder = JSONDecoder()) -> Self {
        .init { data in
            guard let data = data else { return nil }
            return try decoder.decode(Body.self, from: data)
        }
    }
    
    static var `default`: Self {
        .json()
    }
    
}
