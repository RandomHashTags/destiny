
import DestinyDefaults

extension HTTPStandardResponseHeader: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "acceptPatch": self = .acceptPatch
        case "acceptRanges": self = .acceptRanges
        case "accessControlAllowOrigin": self = .accessControlAllowOrigin
        case "accessControlAllowCredentials": self = .accessControlAllowCredentials
        case "accessControlAllowHeaders": self = .accessControlAllowHeaders
        case "accessControlAllowMethods": self = .accessControlAllowMethods
        case "accessControlExposeHeaders": self = .accessControlExposeHeaders
        case "accessControlMaxAge": self = .accessControlMaxAge
        case "age": self = .age
        case "allow": self = .allow
        case "altSvc": self = .altSvc
        case "cacheControl": self = .cacheControl
        case "connection": self = .connection
        case "contentDisposition": self = .contentDisposition
        case "contentEncoding": self = .contentEncoding
        case "contentLanguage": self = .contentLanguage
        case "contentLength": self = .contentLength
        case "contentLocation": self = .contentLocation
        case "contentRange": self = .contentRange
        case "contentType": self = .contentType
        case "date": self = .date
        case "deltaBase": self = .deltaBase
        case "eTag": self = .eTag
        case "expires": self = .expires
        case "im": self = .im
        case "lastModified": self = .lastModified
        case "link": self = .link
        case "location": self = .location
        case "p3p": self = .p3p
        case "pragma": self = .pragma
        case "preferenceApplied": self = .preferenceApplied
        case "proxyAuthenticate": self = .proxyAuthenticate
        case "publicKeyPins": self = .publicKeyPins
        case "retryAfter": self = .retryAfter
        case "server": self = .server
        case "setCookie": self = .setCookie
        case "strictTransportSecurity": self = .strictTransportSecurity
        case "tk": self = .tk
        case "trailer": self = .trailer
        case "transferEncoding": self = .transferEncoding
        case "upgrade": self = .upgrade
        case "vary": self = .vary
        case "via": self = .via
        case "wwwAuthenticate": self = .wwwAuthenticate
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: RawValue {
        switch self {
        case .acceptPatch: "acceptPatch"
        case .acceptRanges: "acceptRanges"
        case .accessControlAllowOrigin: "accessControlAllowOrigin"
        case .accessControlAllowCredentials: "accessControlAllowCredentials"
        case .accessControlAllowHeaders: "accessControlAllowHeaders"
        case .accessControlAllowMethods: "accessControlAllowMethods"
        case .accessControlExposeHeaders: "accessControlExposeHeaders"
        case .accessControlMaxAge: "accessControlMaxAge"
        case .age: "age"
        case .allow: "allow"
        case .altSvc: "altSvc"
        case .cacheControl: "cacheControl"
        case .connection: "connection"
        case .contentDisposition: "contentDisposition"
        case .contentEncoding: "contentEncoding"
        case .contentLanguage: "contentLanguage"
        case .contentLength: "contentLength"
        case .contentLocation: "contentLocation"
        case .contentRange: "contentRange"
        case .contentType: "contentType"
        case .date: "date"
        case .deltaBase: "deltaBase"
        case .eTag: "eTag"
        case .expires: "expires"
        case .im: "im"
        case .lastModified: "lastModified"
        case .link: "link"
        case .location: "location"
        case .p3p: "p3p"
        case .pragma: "pragma"
        case .preferenceApplied: "preferenceApplied"
        case .proxyAuthenticate: "proxyAuthenticate"
        case .publicKeyPins: "publicKeyPins"
        case .retryAfter: "retryAfter"
        case .server: "server"
        case .setCookie: "setCookie"
        case .strictTransportSecurity: "strictTransportSecurity"
        case .tk: "tk"
        case .trailer: "trailer"
        case .transferEncoding: "transferEncoding"
        case .upgrade: "upgrade"
        case .vary: "vary"
        case .via: "via"
        case .wwwAuthenticate: "wwwAuthenticate"
        }
    }
}