//
//  Protocols.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

protocol JSONKey {
    var rawValue: String { get }
}

protocol JSONSerializable {
    var jsonObject: [String: Any] { get }
    static func parse(jsonObject: Any) throws -> Self
}
