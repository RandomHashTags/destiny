//
//  HTTPHeaderParse.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import HTTPTypes
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public extension HTTPField.Name {
    init?(caseName: String) {
        switch caseName {
        case "accept":                          self = .accept
        case "acceptEncoding":                  self = .acceptEncoding
        case "acceptLanguage":                  self = .acceptLanguage
        case "acceptRanges":                    self = .acceptRanges
        case "accessControlAllowCredentials":   self = .accessControlAllowCredentials
        case "accessControlAllowHeaders":       self = .accessControlAllowHeaders
        case "accessControlAllowMethods":       self = .accessControlAllowMethods
        case "accessControlAllowOrigin":        self = .accessControlAllowOrigin
        case "accessControlExposeHeaders":      self = .accessControlExposeHeaders
        case "accessControlMaxAge":             self = .accessControlMaxAge
        case "accessControlRequestHeaders":     self = .accessControlRequestHeaders
        case "accessControlRequestMethod":      self = .accessControlRequestMethod
        case "age":                             self = .age
        case "allow":                           self = .allow
        case "authenticationInfo":              self = .authenticationInfo
        case "authorization":                   self = .authorization
        case "cacheControl":                    self = .cacheControl
        case "connection":                      self = .connection
        case "contentDisposition":              self = .contentDisposition
        case "contentEncoding":                 self = .contentEncoding
        case "contentLanguage":                 self = .contentLanguage
        case "contentLength":                   self = .contentLength
        case "contentLocation":                 self = .contentLocation
        case "contentRange":                    self = .contentRange
        case "contentSecurityPolicy":           self = .contentSecurityPolicy
        case "contentSecurityPolicyReportOnly": self = .contentSecurityPolicyReportOnly
        case "contentType":                     self = .contentType
        case "cookie":                          self = .cookie
        case "crossOriginResourcePolicy":       self = .crossOriginResourcePolicy
        case "date":                            self = .date
        case "earlyData":                       self = .earlyData
        case "eTag":                            self = .eTag
        case "expect":                          self = .expect
        case "expires":                         self = .expires
        case "from":                            self = .from
        case "ifMatch":                         self = .ifMatch
        case "ifModifiedSince":                 self = .ifModifiedSince
        case "ifNoneMatch":                     self = .ifNoneMatch
        case "ifRange":                         self = .ifRange
        case "ifUnmodifiedSince":               self = .ifUnmodifiedSince
        case "lastModified":                    self = .lastModified
        case "location":                        self = .location
        case "maxForwards":                     self = .maxForwards
        case "origin":                          self = .origin
        case "priority":                        self = .priority
        case "proxyAuthenticate":               self = .proxyAuthenticate
        case "proxyAuthenticationInfo":         self = .proxyAuthenticationInfo
        case "proxyAuthorization":              self = .proxyAuthorization
        case "proxyStatus":                     self = .proxyStatus
        case "range":                           self = .range
        case "referer":                         self = .referer
        case "retryAfter":                      self = .retryAfter
        case "secPurpose":                      self = .secPurpose
        case "secWebSocketAccept":              self = .secWebSocketAccept
        case "secWebSocketExtensions":          self = .secWebSocketExtensions
        case "secWebSocketKey":                 self = .secWebSocketKey
        case "secWebSocketProtocol":            self = .secWebSocketProtocol
        case "secWebSocketVersion":             self = .secWebSocketVersion
        case "server":                          self = .server
        case "strictTransportSecurity":         self = .strictTransportSecurity
        case "te":                              self = .te
        case "trailer":                         self = .trailer
        case "transferEncoding":                self = .transferEncoding
        case "upgrade":                         self = .upgrade
        case "userAgent":                       self = .userAgent
        case "vary":                            self = .vary
        case "via":                             self = .via
        case "wwwAuthenticate":                 self = .wwwAuthenticate
        case "xContentTypeOptions":             self = .xContentTypeOptions
        default: return nil
        }
    }
}

public extension HTTPField {
    /// - Returns: The valid headers in a dictionary.
    static func parse(context: some MacroExpansionContext, _ expr: ExprSyntax) -> [String:String] {
        guard let dictionary:[(String, String)] = expr.dictionary?.content.as(DictionaryElementListSyntax.self)?.compactMap({
            guard let key:String = HTTPField.Name.parse(context: context, $0.key) else { return nil }
            let value:String = $0.value.stringLiteral?.string ?? ""
            return (key, value)
        }) else {
            return [:]
        }
        var headers:[String:String] = [:]
        headers.reserveCapacity(dictionary.count)
        for (key, value) in dictionary {
            headers[key] = value
        }
        return headers
    }
}
public extension HTTPField.Name {
    static func parse(context: some MacroExpansionContext, _ expr: ExprSyntax) -> String? {
        guard let key:String = expr.stringLiteral?.string else { return nil }
        guard !key.contains(" ") else {
            context.diagnose(Diagnostic(node: expr, message: DiagnosticMsg(id: "spacesNotAllowedInHTTPFieldName", message: "Spaces aren't allowed in HTTP field names.")))
            return nil
        }
        return key
    }
}