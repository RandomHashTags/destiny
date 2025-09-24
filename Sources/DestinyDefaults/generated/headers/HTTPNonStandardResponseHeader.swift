
#if HTTPNonStandardResponseHeaders

public enum HTTPNonStandardResponseHeader {
    case contentSecurityPolicy
    case expectCT
    case nel
    case permissionsPolicy
    case refresh
    case reportTo
    case status
    case timingAllowOrigin
    case xContentSecurityPolicy
    case xContentTypeOptions
    case xCorrelationID
    case xPoweredBy
    case xRedirectBy
    case xRequestID
    case xUACompatible
    case xWebKitCSP
    case xXSSProtection

    #if Inlinable
    @inlinable
    #endif
    public var rawName: String {
        switch self {
        case .contentSecurityPolicy: "Content-Security-Policy"
        case .expectCT: "Expect-CT"
        case .nel: "NEL"
        case .permissionsPolicy: "Permissions-Policy"
        case .refresh: "Refresh"
        case .reportTo: "Report-To"
        case .status: "Status"
        case .timingAllowOrigin: "Timing-Allow-Origin"
        case .xContentSecurityPolicy: "X-Content-Security-Policy"
        case .xContentTypeOptions: "X-Content-Type-Options"
        case .xCorrelationID: "X-Correlation-ID"
        case .xPoweredBy: "X-Powered-By"
        case .xRedirectBy: "X-Redirect-By"
        case .xRequestID: "X-Request-ID"
        case .xUACompatible: "X-UA-Compatible"
        case .xWebKitCSP: "X-WebKit-CSP"
        case .xXSSProtection: "X-XSS-Protection"
        }
    }
}

#if HTTPNonStandardResponseHeaderHashable
extension HTTPNonStandardResponseHeader: Hashable {
}
#endif

#if HTTPNonStandardResponseHeaderRawValues
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
#endif

#endif