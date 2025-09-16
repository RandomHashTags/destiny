
public enum HTTPNonStandardResponseHeader: Hashable {
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