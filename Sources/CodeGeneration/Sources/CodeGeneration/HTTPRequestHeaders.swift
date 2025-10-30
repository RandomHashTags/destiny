
struct HTTPRequestHeaders {
    static func generateSources() -> [(fileName: String, content: String)] {
        let array = [
            ("Standard", standard),
            ("NonStandard", nonStandard)
        ]
        return array.map({
            ("HTTP\($0.0)RequestHeader.swift", generate(type: $0.0, $0.1))
        })
    }
}

extension HTTPRequestHeaders {
    private static func generate(type: String, _ values: [(String, String)]) -> String {
        let name = "HTTP\(type)RequestHeader"
        var rawValueInitCases = [String]()
        var rawValueCases = [String]()
        var cases = [String]()
        var rawNames = [String]()
        var canonicalNames = [String]()
        for (caseName, name) in values {
            rawValueInitCases.append("        case \"\(caseName)\": self = .\(caseName)")
            rawValueCases.append("        case .\(caseName): \"\(caseName)\"")
            cases.append("    case \(caseName)")
            rawNames.append("        case .\(caseName): \"\(name)\"")
            canonicalNames.append("        case .\(caseName): \"\(name.lowercased())\"")
        }
        let comment = type == "Standard" ? "/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields\n" : ""
        return """

        #if \(name)s
        
        \(comment)public enum \(name) {
        \(cases.joined(separator: "\n"))

            /// Lowercased canonical name of the header used for comparison.
            public var canonicalName: String {
                switch self {
        \(canonicalNames.joined(separator: "\n"))
                }
            }
        }

        #if \(name)RawNames
        extension \(name) {
            public var rawName: String {
                switch self {
        \(rawNames.joined(separator: "\n"))
                }
            }
        }
        #endif

        #if \(name)Hashable
        extension \(name): Hashable {
        }
        #endif

        #if \(name)RawValues
        extension \(name): RawRepresentable {
            public typealias RawValue = String

            public init?(rawValue: RawValue) {
                switch rawValue {
        \(rawValueInitCases.joined(separator: "\n"))
                default: return nil
                }
            }

            public var rawValue: RawValue {
                switch self {
        \(rawValueCases.joined(separator: "\n"))
                }
            }
        }
        #endif

        #endif
        """
    }
}

// MARK: Standard
extension HTTPRequestHeaders {
    private static var standard: [(String, String)] {
        [
            ("aim", "A-IM"),
            ("accept", "Accept"),
            ("acceptCharset", "Accept-Charset"),
            ("acceptDatetime", "Accept-Datetime"),
            ("acceptEncoding", "Accept-Encoding"),
            ("acceptLanguage", "Accept-Language"),
            ("accessControlRequestHeaders", "Access-Control-Request-Headers"),
            ("accessControlRequestMethod", "Access-Control-Request-Method"),
            ("authorization", "Authorization"),

            ("cacheControl", "Cache-Control"),
            ("connection", "Connection"),
            ("contentEncoding", "Content-Encoding"),
            ("contentLength", "Content-Length"),
            ("contentType", "Content-Type"),
            ("cookie", "Cookie"),

            ("date", "Date"),

            ("expect", "Expect"),

            ("forwarded", "Forwarded"),
            ("from", "From"),

            ("host", "Host"),

            ("ifMatch", "If-Match"),
            ("ifModifiedSince", "If-Modified-Since"),
            ("ifNoneMatch", "If-None-Match"),
            ("ifRange", "If-Range"),
            ("ifUnmodifiedSince", "If-Unmodified-Since"),

            ("maxForwards", "Max-Forwards"),

            ("origin", "Origin"),

            ("pragma", "Pragma"),
            ("prefer", "Prefer"),
            ("proxyAuthorization", "Proxy-Authorization"),

            ("range", "Range"),
            ("referer", "Referer"),

            ("te", "TE"),
            ("trailer", "Trailer"),
            ("transferEncoding", "Transfer-Encoding"),

            ("upgrade", "Upgrade"),
            ("userAgent", "User-Agent"),

            ("via", "Via")
        ]
    }
}

// MARK: Non-standard
extension HTTPRequestHeaders {
    private static var nonStandard: [(String, String)] {
        [
            ("correlationID", "Correlation-ID"),

            ("dnt", "DNT"),

            ("frontEndHttps", "Front-End-Https"),

            ("proxyConnection", "Proxy-Connection"),

            ("saveData", "Save-Data"),
            ("secGPC", "Sec-GPC"),

            ("upgradeInsecureRequests", "Upgrade-Insecure-Requests"),

            ("xATTDeviceID", "X-ATT-Device-Id"),
            ("xCorrelationID", "X-Correlation-ID"),
            ("xCsrfToken", "X-Csrf-Token"),
            ("xForwardedFor", "X-Forwarded-For"),
            ("xForwardedHost", "X-Forwarded-Host"),
            ("xForwardedProto", "X-Forwarded-Proto"),
            ("xHttpMethodOverride", "X-Http-Method-Override"),
            ("xRequestID", "X-Request-ID"),
            ("xRequestedWith", "X-Requested-With"),
            ("xUIDH", "X-UIDH"),
            ("xWapProfile", "X-Wap-Profile"),
        ]
    }
}