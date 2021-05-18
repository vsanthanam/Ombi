//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/17/21.
//

import Foundation

public extension URLRequest {
    
    /// The `RequestMethod` of this URL Request
    var requestMethod: RequestMethod? {
        httpMethod.flatMap(RequestMethod.init)
    }
 
}
