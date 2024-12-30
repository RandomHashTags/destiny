//
//  HTTPRequestMethodExtensions.swift
//
//
//  Created by Evan Anderson on 11/2/24.
//

import HTTPTypes
import SwiftSyntax

public extension HTTPRequest.Method {
    // MARK: Init ExprSyntax
    init?(expr: ExprSyntax) {
        guard let caseName:String = expr.memberAccess?.declName.baseName.text, let method:HTTPRequest.Method = HTTPRequest.Method(rawValue: caseName.uppercased()) else { return nil }
        self = method
    }

    // MARK: Parse by key
    static func parse(_ key: String) -> Self? {
        switch key {
        case "get", "GET":         return .get
        case "head", "HEAD":       return .head
        case "post", "POST":       return .post
        case "put", "PUT":         return .put
        case "delete", "DELETE":   return .delete
        case "connect", "CONNECT": return .connect
        case "options", "OPTIONS": return .options
        case "trace", "TRACE":     return .trace
        case "patch", "PATCH":     return .patch
        default:                   return .init(key)
        }
    }

    // MARK: Parse by SIMD key
    static func parse(_ key: StackString8) -> Self? {
        switch key {
        case Self.getSIMD:     return .get
        case Self.headSIMD:    return .head
        case Self.postSIMD:    return .post
        case Self.putSIMD:     return .put
        case Self.deleteSIMD:  return .delete
        case Self.connectSIMD: return .connect
        case Self.optionsSIMD: return .options
        case Self.traceSIMD:   return .trace
        case Self.patchSIMD:   return .patch
        default:               return .init(key.stringSIMD())
        }
    }
    static let getSIMD:StackString8 = StackString8(71, 69, 84, 0, 0, 0, 0, 0)
    static let headSIMD:StackString8 = StackString8(72, 69, 65, 68, 0, 0, 0, 0)
    static let postSIMD:StackString8 = StackString8(80, 79, 83, 84, 0, 0, 0, 0)
    static let putSIMD:StackString8 = StackString8(80, 85, 84, 0, 0, 0, 0, 0)
    static let deleteSIMD:StackString8 = StackString8(68, 69, 76, 69, 84, 69, 0, 0)
    static let connectSIMD:StackString8 = StackString8(67, 79, 78, 78, 69, 67, 84, 0)
    static let optionsSIMD:StackString8 = StackString8(79, 80, 84, 73, 79, 78, 83, 0)
    static let traceSIMD:StackString8 = StackString8(84, 82, 65, 67, 69, 0, 0, 0)
    static let patchSIMD:StackString8 = StackString8(80, 65, 84, 67, 72, 0, 0, 0)
}

// MARK: CustomDebugStringConvertible
extension HTTPRequest.Method : CustomDebugStringConvertible {
    public var debugDescription : String {
        return "HTTPRequest.Method(\"\(rawValue)\")!"
    }
}