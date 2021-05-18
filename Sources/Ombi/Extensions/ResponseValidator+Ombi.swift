//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

public extension ResponseValidator where Error == HTTPError {
    
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
    
    static var `unsafe`: Self {
        .init { .success($0) }
    }
    
}
