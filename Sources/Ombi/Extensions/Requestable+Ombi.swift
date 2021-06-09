// Ombi
// Requestable+Ombi.swift
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

public extension Requestable {
    var authentication: RequestAuthentication? {
        nil
    }

    var responseValidator: ResponseValidator<ResponseBody, ResponseError> {
        .unsafe
    }

    var fallbackResponse: Response? {
        nil
    }

    var timeoutInterval: TimeInterval {
        120.0
    }

    var query: [URLQueryItem] {
        []
    }
}

public extension Requestable where ResponseError == HTTPError {
    var responseValidator: ResponseValidator<ResponseBody, ResponseError> {
        .default
    }
}

public extension Requestable where ResponseError == NoError {
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

public extension Requestable where RequestBody: AutomaticBodyEncoding {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody: AutomaticBodyDecoding {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}

public extension Requestable where RequestBody == NoBody {
    var requestEncoder: BodyEncoder<RequestBody> {
        .default
    }
}

public extension Requestable where ResponseBody == NoBody {
    var responseDecoder: BodyDecoder<ResponseBody> {
        .default
    }
}
