//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/20/21.
//

import Foundation

public typealias AutomaticBodyCoding = AutomaticBodyEncoding & AutomaticBodyDecoding

public protocol AutomaticBodyEncoding {
    func asData() throws -> Data?
}

public protocol AutomaticBodyDecoding {
    init?(fromData: Data?) throws
}
