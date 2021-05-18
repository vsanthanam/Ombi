//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public struct ResponseValidator<Body, Error> where Error: Swift.Error {
    
    public init(_ handler: @escaping Handler) {
        self.handle = handler
    }
    
    public typealias Response = RequestResponse<Body>
    public typealias Handler = (Response) -> Response.Validation<Error>
    
    public let handle: Handler
    
}
