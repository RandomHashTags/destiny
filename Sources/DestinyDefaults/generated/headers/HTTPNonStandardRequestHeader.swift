
public enum HTTPNonStandardRequestHeader: Hashable {
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