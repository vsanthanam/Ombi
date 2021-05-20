//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

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
    static var `unsafe`: Self {
        .init { .success($0) }
    }
    
}
