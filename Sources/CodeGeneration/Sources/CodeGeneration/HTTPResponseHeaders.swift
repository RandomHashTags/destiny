
struct HTTPResponseHeaders {
    static func generateSources() -> [(fileName: String, content: String)] {
        let array = [
            ("Standard", standard),
            ("NonStandard", nonStandard)
        ]
        return array.map({
            ("HTTP\($0.0)ResponseHeader.swift", generate(type: $0.0, $0.1))
        })
    }
}

extension HTTPResponseHeaders {
    private static func generate(type: String, _ values: [(String, String)]) -> String {
        let name = "HTTP\(type)ResponseHeader"
        var rawValueInitCases = [String]()
        var rawValueCases = [String]()
        var cases = [String]()
        var rawNames = [String]()
        for value in values {
            rawValueInitCases.append("        case \"\(value.0)\": self = .\(value.0)")
            rawValueCases.append("        case .\(value.0): \"\(value.0)\"")
            cases.append("    case \(value.0)")
            rawNames.append("        case .\(value.0): \"\(value.1)\"")
        }
        let comment = type == "Standard" ? "/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Response_fields\n" : ""
        return """
        
        \(comment)public enum \(name): Hashable {
        \(cases.joined(separator: "\n"))

            #if Inlinable
            @inlinable
            #endif
            public var rawName: String {
                switch self {
        \(rawNames.joined(separator: "\n"))
                }
            }
        }

        extension \(name): RawRepresentable {
            public typealias RawValue = String

            #if Inlinable
            @inlinable
            #endif
            public init?(rawValue: RawValue) {
                switch rawValue {
        \(rawValueInitCases.joined(separator: "\n"))
                default: return nil
                }
            }

            #if Inlinable
            @inlinable
            #endif
            public var rawValue: RawValue {
                switch self {
        \(rawValueCases.joined(separator: "\n"))
                }
            }
        }
        """
    }
}

// MARK: Standard
extension HTTPResponseHeaders {
    private static var standard: [(String, String)] {
        [
            ("acceptPatch", "Accept-Patch"),
            ("acceptRanges", "Accept-Ranges"),
            ("accessControlAllowOrigin", "Access-Control-Allow-Origin"),
            ("accessControlAllowCredentials", "Access-Control-Allow-Credentials"),
            ("accessControlAllowHeaders", "Access-Control-Allow-Headers"),
            ("accessControlAllowMethods", "Access-Control-Allow-Methods"),
            ("accessControlExposeHeaders", "Access-Control-Expose-Headers"),
            ("accessControlMaxAge", "Access-Control-Max-Age"),
            ("age", "Age"),
            ("allow", "Allow"),
            ("altSvc", "Alt-Svc"),

            ("cacheControl", "Cache-Control"),
            ("connection", "Connection"),
            ("contentDisposition", "Content-Disposition"),
            ("contentEncoding", "Content-Encoding"),
            ("contentLanguage", "Content-Language"),
            ("contentLength", "Content-Length"),
            ("contentLocation", "Content-Location"),
            ("contentRange", "Content-Range"),
            ("contentType", "Content-Type"),

            ("date", "Date"),
            ("deltaBase", "Delta-Base"),

            ("eTag", "ETag"),
            ("expires", "Expires"),

            ("im", "IM"),

            ("lastModified", "Last-Modified"),
            ("link", "Link"),
            ("location", "Location"),

            ("p3p", "P3P"),
            ("pragma", "Pragma"),
            ("preferenceApplied", "Preference-Applied"),
            ("proxyAuthenticate", "Proxy-Authenticate"),
            ("publicKeyPins", "Public-Key-Pins"),

            ("retryAfter", "Retry-After"),


            ("server", "Server"),
            ("setCookie", "Set-Cookie"),
            ("strictTransportSecurity", "Strict-Transport-Security"),

            ("tk", "TK"),
            ("trailer", "Trailer"),
            ("transferEncoding", "Transfer-Encoding"),

            ("upgrade", "Upgrade"),

            ("vary", "Vary"),
            ("via", "Via"),

            ("wwwAuthenticate", "WWW-Authenticate")
        ]
    }
}

// MARK: Non-standard
extension HTTPResponseHeaders {
    private static var nonStandard: [(String, String)] {
        [
            ("contentSecurityPolicy", "Content-Security-Policy"),

            ("expectCT", "Expect-CT"),

            ("nel", "NEL"),
            
            ("permissionsPolicy", "Permissions-Policy"),

            ("refresh", "Refresh"),
            ("reportTo", "Report-To"),

            ("status", "Status"),

            ("timingAllowOrigin", "Timing-Allow-Origin"),

            ("xContentSecurityPolicy", "X-Content-Security-Policy"),
            ("xContentTypeOptions", "X-Content-Type-Options"),
            ("xCorrelationID", "X-Correlation-ID"),
            ("xPoweredBy", "X-Powered-By"),
            ("xRedirectBy", "X-Redirect-By"),
            ("xRequestID", "X-Request-ID"),
            ("xUACompatible", "X-UA-Compatible"),
            ("xWebKitCSP", "X-WebKit-CSP"),
            ("xXSSProtection", "X-XSS-Protection")
        ]
    }
}