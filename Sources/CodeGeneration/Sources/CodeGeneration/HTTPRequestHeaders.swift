
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
        let cases = values.map({ "    case \($0.0)" }).joined(separator: "\n")
        let rawNames = values.map({ "        case .\($0.0): \"\($0.1)\"" }).joined(separator: "\n")
        let comment = type == "Standard" ? "/// https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Request_fields\n" : ""
        return """
        
        \(comment)public enum HTTP\(type)RequestHeader: String, Hashable {
        \(cases)

            @inlinable
            public var rawName: String {
                switch self {
        \(rawNames)
                }
            }
        }
        
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