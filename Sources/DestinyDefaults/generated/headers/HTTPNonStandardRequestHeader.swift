
#if HTTPNonStandardRequestHeaders

public enum HTTPNonStandardRequestHeader {
    case correlationID
    case dnt
    case frontEndHttps
    case proxyConnection
    case saveData
    case secGPC
    case upgradeInsecureRequests
    case xATTDeviceID
    case xCorrelationID
    case xCsrfToken
    case xForwardedFor
    case xForwardedHost
    case xForwardedProto
    case xHttpMethodOverride
    case xRequestID
    case xRequestedWith
    case xUIDH
    case xWapProfile

    #if Inlinable
    @inlinable
    #endif
    public var rawName: String {
        switch self {
        case .correlationID: "Correlation-ID"
        case .dnt: "DNT"
        case .frontEndHttps: "Front-End-Https"
        case .proxyConnection: "Proxy-Connection"
        case .saveData: "Save-Data"
        case .secGPC: "Sec-GPC"
        case .upgradeInsecureRequests: "Upgrade-Insecure-Requests"
        case .xATTDeviceID: "X-ATT-Device-Id"
        case .xCorrelationID: "X-Correlation-ID"
        case .xCsrfToken: "X-Csrf-Token"
        case .xForwardedFor: "X-Forwarded-For"
        case .xForwardedHost: "X-Forwarded-Host"
        case .xForwardedProto: "X-Forwarded-Proto"
        case .xHttpMethodOverride: "X-Http-Method-Override"
        case .xRequestID: "X-Request-ID"
        case .xRequestedWith: "X-Requested-With"
        case .xUIDH: "X-UIDH"
        case .xWapProfile: "X-Wap-Profile"
        }
    }
}

#if HTTPNonStandardRequestHeaderHashable
extension HTTPNonStandardRequestHeader: Hashable {
}
#endif

#if HTTPNonStandardRequestHeaderRawValues
extension HTTPNonStandardRequestHeader: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "correlationID": self = .correlationID
        case "dnt": self = .dnt
        case "frontEndHttps": self = .frontEndHttps
        case "proxyConnection": self = .proxyConnection
        case "saveData": self = .saveData
        case "secGPC": self = .secGPC
        case "upgradeInsecureRequests": self = .upgradeInsecureRequests
        case "xATTDeviceID": self = .xATTDeviceID
        case "xCorrelationID": self = .xCorrelationID
        case "xCsrfToken": self = .xCsrfToken
        case "xForwardedFor": self = .xForwardedFor
        case "xForwardedHost": self = .xForwardedHost
        case "xForwardedProto": self = .xForwardedProto
        case "xHttpMethodOverride": self = .xHttpMethodOverride
        case "xRequestID": self = .xRequestID
        case "xRequestedWith": self = .xRequestedWith
        case "xUIDH": self = .xUIDH
        case "xWapProfile": self = .xWapProfile
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: RawValue {
        switch self {
        case .correlationID: "correlationID"
        case .dnt: "dnt"
        case .frontEndHttps: "frontEndHttps"
        case .proxyConnection: "proxyConnection"
        case .saveData: "saveData"
        case .secGPC: "secGPC"
        case .upgradeInsecureRequests: "upgradeInsecureRequests"
        case .xATTDeviceID: "xATTDeviceID"
        case .xCorrelationID: "xCorrelationID"
        case .xCsrfToken: "xCsrfToken"
        case .xForwardedFor: "xForwardedFor"
        case .xForwardedHost: "xForwardedHost"
        case .xForwardedProto: "xForwardedProto"
        case .xHttpMethodOverride: "xHttpMethodOverride"
        case .xRequestID: "xRequestID"
        case .xRequestedWith: "xRequestedWith"
        case .xUIDH: "xUIDH"
        case .xWapProfile: "xWapProfile"
        }
    }
}
#endif

#endif