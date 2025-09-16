
import DestinyDefaults

extension HTTPNonStandardResponseHeader: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "contentSecurityPolicy": self = .contentSecurityPolicy
        case "expectCT": self = .expectCT
        case "nel": self = .nel
        case "permissionsPolicy": self = .permissionsPolicy
        case "refresh": self = .refresh
        case "reportTo": self = .reportTo
        case "status": self = .status
        case "timingAllowOrigin": self = .timingAllowOrigin
        case "xContentSecurityPolicy": self = .xContentSecurityPolicy
        case "xContentTypeOptions": self = .xContentTypeOptions
        case "xCorrelationID": self = .xCorrelationID
        case "xPoweredBy": self = .xPoweredBy
        case "xRedirectBy": self = .xRedirectBy
        case "xRequestID": self = .xRequestID
        case "xUACompatible": self = .xUACompatible
        case "xWebKitCSP": self = .xWebKitCSP
        case "xXSSProtection": self = .xXSSProtection
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: RawValue {
        switch self {
        case .contentSecurityPolicy: "contentSecurityPolicy"
        case .expectCT: "expectCT"
        case .nel: "nel"
        case .permissionsPolicy: "permissionsPolicy"
        case .refresh: "refresh"
        case .reportTo: "reportTo"
        case .status: "status"
        case .timingAllowOrigin: "timingAllowOrigin"
        case .xContentSecurityPolicy: "xContentSecurityPolicy"
        case .xContentTypeOptions: "xContentTypeOptions"
        case .xCorrelationID: "xCorrelationID"
        case .xPoweredBy: "xPoweredBy"
        case .xRedirectBy: "xRedirectBy"
        case .xRequestID: "xRequestID"
        case .xUACompatible: "xUACompatible"
        case .xWebKitCSP: "xWebKitCSP"
        case .xXSSProtection: "xXSSProtection"
        }
    }
}