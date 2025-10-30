
struct HTTPResponseStatuses {
    static func generateSources() -> [(fileName: String, content: String)] {
        let array = [
            ("Standard", standard),
            ("NonStandard", nonStandard)
        ]
        return array.map({
            ("HTTP\($0.0)ResponseStatus.swift", generate(type: $0.0, $0.1))
        })
    }
}

extension HTTPResponseStatuses {
    static func generate(type: String, _ values: [(name: String, code: UInt16)]) -> String {
        let comment:(UInt16) -> String = type == "Standard" ? {
            "    /// https://www.rfc-editor.org/rfc/rfc9110.html#status.\($0)\n"
        } : { _ in "" }
        var cases = [String]()
        var codeCases = [String]()
        var rawValueInits = [String]()
        var rawValueCases = [String]()
        for (name, code) in values {
            cases.append("\(comment(code))    case \(name)")
            codeCases.append("        case .\(name): \(code)")

            let rawValue:String
            var names = ["\"\(name)\""]
            if name.first == "`" {
                rawValue = name.replacingOccurrences(of: "`", with: "")
                names.append("\"\(rawValue)\"")
            } else {
                rawValue = name
            }
            rawValueInits.append("        case \(names.joined(separator: ", ")): self = .\(name)")
            rawValueCases.append("        case .\(name): \"\(rawValue)\"")
        }
        let name = "HTTP\(type)ResponseStatus"
        return """

        #if \(name)es

        import DestinyBlueprint

        public enum \(name): HTTPResponseStatus.StorageProtocol {
        \(cases.joined(separator: "\n"))

            public var code: UInt16 {
                switch self {
        \(codeCases.joined(separator: "\n"))
                }
            }
        }

        #if \(name)RawValues
        extension \(name): RawRepresentable {
            public typealias RawValue = String

            public init?(rawValue: RawValue) {
                switch rawValue {
        \(rawValueInits.joined(separator: "\n"))
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
extension HTTPResponseStatuses {
    static var standard: [(name: String, code: UInt16)] {
        [
            // 1xx
            ("`continue`", 100),
            ("switchingProtocols", 101),
            ("processing", 102), // deprecated
            ("earlyHints", 103),

            // 2xx
            ("ok", 200),
            ("created", 201),
            ("accepted", 202),
            ("nonAuthoritativeInformation", 203),
            ("noContent", 204),
            ("resetContent", 205),
            ("partialContent", 206),
            ("multiStatus", 207),
            ("alreadyReported", 208),
            ("imUsed", 226),

            // 3xx
            ("multipleChoices", 300),
            ("movedPermanently", 301),
            ("found", 302),
            ("seeOther", 303),
            ("notModified", 304),
            ("useProxy", 305),
            ("temporaryRedirect", 307),
            ("permanentRedirect", 308),

            // 4xx
            ("badRequest", 400),
            ("unauthorized", 401),
            ("paymentRequired", 402),
            ("forbidden", 403),
            ("notFound", 404),
            ("methodNotAllowed", 405),
            ("notAcceptable", 406),
            ("proxyAuthenticationRequired", 407),
            ("requestTimeout", 408),
            ("conflict", 409),
            ("gone", 410),
            ("lengthRequired", 411),
            ("preconditionFailed", 412),
            ("payloadTooLarge", 413),
            ("uriTooLong", 414),
            ("unsupportedMediaType", 415),
            ("rangeNotSatisfiable", 416),
            ("expectationFailed", 417),
            ("imATeapot", 418),
            ("misdirectedRequest", 421),
            ("unprocessableContent", 422),
            ("locked", 423),
            ("failedDependency", 424),
            ("tooEarly", 425),
            ("upgradeRequired", 426),
            ("preconditionRequired", 428),
            ("tooManyRequests", 429),
            ("requestHeaderFieldsTooLarge", 431),
            ("unavailableForLegalReasons", 451),

            // 5xx
            ("internalServerError", 500),
            ("notImplemented", 501),
            ("badGateway", 502),
            ("serviceUnavailable", 503),
            ("gatewayTimeout", 504),
            ("httpVersionNotSupported", 505),
            ("variantAlsoNegotiates", 506),
            ("insufficientStorage", 507),
            ("loopDetected", 508),
            ("notExtended", 510),
            ("networkAuthenticationRequired", 511)
        ]
    }
}

// MARK: Non-standard
extension HTTPResponseStatuses {
    static var nonStandard: [(name: String, code: UInt16)] {
        [
            // Unofficial
            ("thisIsFine", 218),
            ("pageExpired", 419),
            ("methodFailure", 420),
            ("enhanceYourCalm", 420),
            ("shopifySecurityRejection", 430),
            ("blockedByWindowsParentalControls", 450),
            ("invalidToken", 498),
            ("tokenRequired", 499),
            ("bandwidthLimitExceeded", 509),
            ("siteIsOverloaded", 529),
            ("siteIsFrozen", 530),
            ("originDNSError", 530),
            ("temporarilyDisabled", 540),
            ("networkReadTimeoutError", 598),
            ("networkConnectTimeoutError", 599),
            ("unexpectedToken", 783),
            ("nonStandard", 999),

            // Internet Information Services
            ("loginTimeout", 440),
            ("retryWith", 449),
            ("redirect", 451),

            // nginx
            ("noResponse", 444),
            ("requestHeaderTooLarge", 494),
            ("sslCertificateError", 495),
            ("sslCertificateRequired", 496),
            ("httpRequestSendToHTTPSPort", 497),
            ("clientClosedRequest", 499),

            // Cloudflare
            ("webServerReturnedAnUnknownError", 520),
            ("webServerIsDown", 521),
            ("connectionTimedOut", 522),
            ("originIsUnreachable", 523),
            ("aTimeoutOccurred", 524),
            ("sslHandshakeFailed", 525),
            ("invalidSSLCertificate", 526),
            ("issueResolvingOriginHostname", 530),

            // AWS Elastic Load Balancing
            ("_000", 000),
            ("_460", 460),
            ("_463", 463),
            ("_464", 464),
            ("_561", 561)
        ]
    }
}