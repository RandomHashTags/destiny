//
//  HTTPMediaTypeProtocol.swift
//
//
//  Created by Evan Anderson on 5/18/25.
//

// MARK: HTTPMediaTypeProtocol
public protocol HTTPMediaTypeProtocol: CustomStringConvertible, Sendable {
    var type: String { get }
    var subType: String { get }
}