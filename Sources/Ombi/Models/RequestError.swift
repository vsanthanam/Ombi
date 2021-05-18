//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/8/21.
//

import Foundation

/// An error produced by a `RequestManager`
public enum RequestError<T>: RequestErrorProtocol where T: Error {
    
    /// Malformed Request
    case malformedRequest
    
    /// Decoding
    case decodingError(Error)
    
    /// Unknown
    case unknownError
    
    /// A response validation error
    case validationError(T)
    
    /// Session failed error
    case urlSessionFailed(_ error: URLError)
    
    /// Timeout error
    case timeoutSlaExceeded
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        description
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        switch self {
        case .malformedRequest:
            return "The request was malformed. Check the URL or the body content"
        case .decodingError(let error):
            return "Couldn't decode the response body content: \(error)"
        case .unknownError:
            return "The request failed for an unknown reason"
        case .validationError(let error):
            return "The request failed validation: \(error)"
        case .urlSessionFailed(let error):
            return "The URL session failed: \(error)"
        case .timeoutSlaExceeded:
            return "The request exceeded the timeout sla"
        }
    }
}

/// Basic validation error
public enum HTTPError: LocalizedError, CustomStringConvertible {
    
    // MARK: - Initializers
    
    /// Create an `HTTPError` based on a status code
    /// - Parameter code: The code
    public init?(_ code: Int) {
        guard code < 200 || code >= 300 else {
            return nil
        }
        switch code {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 402, 405...499: self = .error4xx(code)
        case 500: self = .serverError
        case 501...599: self = .error5xx(code)
        default: self =  .unknownErrorCode(code)
        }
    }
    
    // MARK: - API
    
    /// Bad request (400)
    case badRequest
    
    /// Authorization error (401)
    case unauthorized
    
    /// Forbidden error (403)
    case forbidden
    
    /// Not found error (404)
    case notFound
    
    /// Custom 4xx error
    case error4xx(_ code: Int)
    
    /// Server error (500)
    case serverError
    
    /// Custom 5xx error
    case error5xx(_ code: Int)
    
    /// Other http error
    case unknownErrorCode(_ code: Int)
    
    // MARK: - LocalizedError
    
    public var errorDescription: String? {
        description
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        switch self {
        case .badRequest:
            return "Bad Request(400)"
        case .unauthorized:
            return "Unauthorized (401)"
        case .forbidden:
            return "Forbidden (403)"
        case .notFound:
            return "Not Found (404)"
        case .error4xx(let code):
            return "Error (\(code))"
        case .serverError:
            return "Server Error (500)"
        case .error5xx(let code):
            return "Errpr (\(code))"
        case .unknownErrorCode(let code):
            return "Unknown Error (\(code))"
        }
    }
    
}
