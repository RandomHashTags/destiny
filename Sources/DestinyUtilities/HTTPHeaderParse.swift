//
//  HTTPHeaderParse.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

import HTTPTypes

public extension HTTPField.Name {
    static func parse(caseName: String) -> HTTPField.Name? {
        switch caseName {
        case "accept":                          return .accept
        case "acceptEncoding":                  return .acceptEncoding
        case "acceptLanguage":                  return .acceptLanguage
        case "acceptRanges":                    return .acceptRanges
        case "accessControlAllowCredentials":   return .accessControlAllowCredentials
        case "accessControlAllowHeaders":       return .accessControlAllowHeaders
        case "accessControlAllowMethods":       return .accessControlAllowMethods
        case "accessControlAllowOrigin":        return .accessControlAllowOrigin
        case "accessControlExposeHeaders":      return .accessControlExposeHeaders
        case "accessControlMaxAge":             return .accessControlMaxAge
        case "accessControlRequestHeaders":     return .accessControlRequestHeaders
        case "accessControlRequestMethod":      return .accessControlRequestMethod
        case "age":                             return .age
        case "allow":                           return .allow
        case "authenticationInfo":              return .authenticationInfo
        case "authorization":                   return .authorization
        case "cacheControl":                    return .cacheControl
        case "connection":                      return .connection
        case "contentDisposition":              return .contentDisposition
        case "contentEncoding":                 return .contentEncoding
        case "contentLanguage":                 return .contentLanguage
        case "contentLength":                   return .contentLength
        case "contentLocation":                 return .contentLocation
        case "contentRange":                    return .contentRange
        case "contentSecurityPolicy":           return .contentSecurityPolicy
        case "contentSecurityPolicyReportOnly": return .contentSecurityPolicyReportOnly
        case "contentType":                     return .contentType
        case "cookie":                          return .cookie
        case "crossOriginResourcePolicy":       return .crossOriginResourcePolicy
        case "date":                            return .date
        case "earlyData":                       return .earlyData
        case "eTag":                            return .eTag
        case "expect":                          return .expect
        case "expires":                         return .expires
        case "from":                            return .from
        case "ifMatch":                         return .ifMatch
        case "ifModifiedSince":                 return .ifModifiedSince
        case "ifNoneMatch":                     return .ifNoneMatch
        case "ifRange":                         return .ifRange
        case "ifUnmodifiedSince":               return .ifUnmodifiedSince
        case "lastModified":                    return .lastModified
        case "location":                        return .location
        case "maxForwards":                     return .maxForwards
        case "origin":                          return .origin
        case "priority":                        return .priority
        case "proxyAuthenticate":               return .proxyAuthenticate
        case "proxyAuthenticationInfo":         return .proxyAuthenticationInfo
        case "proxyAuthorization":              return .proxyAuthorization
        case "proxyStatus":                     return .proxyStatus
        case "range":                           return .range
        case "referer":                         return .referer
        case "retryAfter":                      return .retryAfter
        case "secPurpose":                      return .secPurpose
        case "secWebSocketAccept":              return .secWebSocketAccept
        case "secWebSocketExtensions":          return .secWebSocketExtensions
        case "secWebSocketKey":                 return .secWebSocketKey
        case "secWebSocketProtocol":            return .secWebSocketProtocol
        case "secWebSocketVersion":             return .secWebSocketVersion
        case "server":                          return .server
        case "strictTransportSecurity":         return .strictTransportSecurity
        case "te":                              return .te
        case "trailer":                         return .trailer
        case "transferEncoding":                return .transferEncoding
        case "upgrade":                         return .upgrade
        case "userAgent":                       return .userAgent
        case "vary":                            return .vary
        case "via":                             return .via
        case "wwwAuthenticate":                 return .wwwAuthenticate
        case "xContentTypeOptions":             return .xContentTypeOptions
            default: return nil
        }
    }
}