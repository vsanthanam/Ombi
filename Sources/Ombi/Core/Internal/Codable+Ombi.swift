//
//  File.swift
//  
//
//  Created by Varun Santhanam on 5/18/21.
//

import Foundation

extension Encodable {
    func encoded() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

extension Decodable {
    static func decoded(from data: Data) throws -> Self {
        try JSONDecoder().decode(self, from: data)
    }
}
