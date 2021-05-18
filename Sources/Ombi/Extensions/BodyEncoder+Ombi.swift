//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public extension BodyEncoder {
    
    static var `fatal`: Self {
        .init { _ in fatalError() }
    }
    
}

public extension BodyEncoder where Body == Data {
    
    static var `default`: Self {
        .init { body in body }
    }
    
}

public extension BodyEncoder where Body == String {
    
    init(encoding: String.Encoding) {
        self = .init { body in
            body?.data(using: encoding)
        }
    }
    
    static var `default`: Self {
        .init(encoding: .utf8)
    }
}

public extension BodyEncoder where Body == AnyJSON {
    
    init(options: JSONSerialization.WritingOptions) {
        self = .init { body in
            guard let body = body else { return nil }
            return try JSONSerialization.data(withJSONObject: body.obj, options: options)
        }
    }
    
    static var `default`: Self {
        .init(options: [])
    }
}

public extension BodyEncoder where Body == RequestParameters {
    
    static var `default`: Self {
        .init { body in
            guard let body = body else { return nil }
            return body.allParameters
                .reduce(Array<String>()) { prev, parameter in
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
    
    static func json(encoder: JSONEncoder = JSONEncoder()) -> Self {
        .init { body in
            guard let body = body else { return nil }
            return try encoder.encode(body)
        }
    }

    static var `default`: Self {
        .json()
    }
}
