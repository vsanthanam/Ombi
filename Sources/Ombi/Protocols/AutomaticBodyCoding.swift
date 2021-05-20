//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/20/21.
//

import Foundation

/// Types that are both `AutomaticBodyEncoding` and `AutomaticBodyDecoding`
public typealias AutomaticBodyCoding = AutomaticBodyEncoding & AutomaticBodyDecoding

/// A protocol for types that can be expressed as  `Data`
public protocol AutomaticBodyEncoding {
    
    /// Convert `self` into `Data?`, or throw and error
    func asData() throws -> Data?
}

/// A protocol for types that can be initialized from  `Data` provided by a network response
public protocol AutomaticBodyDecoding {

    /// Create `Self` from `Data?`, or throw an error
    /// - Parameter fromData: The data to decode
    init?(fromData: Data?) throws
}
