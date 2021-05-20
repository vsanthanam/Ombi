//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public extension Requestable {
    var responseValidator: ResponseValidator<ResponseBody, ResponseError> {
        .unsafe
    }
    var fallbackResponse: Response? {
        nil
    }
    var timeoutInterval: TimeInterval {
        120.0
    }
}

public extension Requestable where ResponseError == HTTPError {
    var responseValidator: ResponseValidator<ResponseBody, ResponseError> {
        .default
    }
}

public extension Requestable where RequestBody == String {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody == String {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}

public extension Requestable where RequestBody == Data {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody == Data {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}

public extension Requestable where RequestBody: Encodable {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody: Decodable {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}

public extension Requestable where RequestBody == AnyJSON {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody == AnyJSON {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}

public extension Requestable where RequestBody == RequestParameters {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}
