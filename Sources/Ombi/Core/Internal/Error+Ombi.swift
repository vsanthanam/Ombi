//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

extension Error {
    func requestError<T: Error>() -> RequestError<T> {
        switch self {
        case is T:
            return .validationError(self as! T)
        case is RequestError<T>:
            return self as! RequestError<T>
        default:
            return .unknownError
        }
    }
}
