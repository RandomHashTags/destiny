//
//  HTTPRequestMethodParse.swift
//
//
//  Created by Evan Anderson on 11/2/24.
//

import HTTPTypes

public extension HTTPRequest.Method {
    // MARK: caseName
    var caseName : String? {
        switch self {
            case .get:     return "get"
            case .head:    return "head"
            case .post:    return "post"
            case .put:     return "put"
            case .delete:  return "delete"
            case .connect: return "connect"
            case .options: return "options"
            case .trace:   return "trace"
            case .patch:   return "patch"
            default:       return nil
        }
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
}