
import DestinyDefaults

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