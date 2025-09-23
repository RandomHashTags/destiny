
struct HTTPRequestMethods {
    static func generateSources() -> [(fileName: String, content: String)] {
        let array = [
            ("Standard", standard),
            ("NonStandard", nonStandard)
        ]
        return array.map({
            ("HTTP\($0.0)RequestMethods.swift", generate(type: $0.0, $0.1))
        })
    }
}

// MARK: Generate
extension HTTPRequestMethods {
    private static func generate(type: String, _ values: [(String, String)]) -> String {
        var cases = [String]()
        var rawValueCases = [String]()
        var rawValueInitCases = [String]()
        var rawNameCaseValues = [String]()
        cases.reserveCapacity(values.count)
        rawValueCases.reserveCapacity(values.count)
        rawValueInitCases.reserveCapacity(values.count)
        rawNameCaseValues.reserveCapacity(values.count)
        for (caseName, name) in values {
            cases.append("    case \(caseName)")
            rawValueCases.append("        case .\(caseName): \"\(caseName)\"")
            rawValueInitCases.append("        case \"\(caseName)\": self = .\(caseName)")
            rawNameCaseValues.append("        case .\(caseName): \"\(name)\"")
        }
        let name = "HTTP\(type)RequestMethod"
        return """

        import DestinyBlueprint

        public enum \(name): HTTPRequestMethodProtocol {
        \(cases.joined(separator: "\n"))

            #if Inlinable
            @inlinable
            #endif
            public func rawNameString() -> String {
                switch self {
        \(rawNameCaseValues.joined(separator: "\n"))
                }
            }
        }

        extension \(name): RawRepresentable {
            public typealias RawValue = String

            #if Inlinable
            @inlinable
            #endif
            public init?(rawValue: String) {
                switch rawValue {
        \(rawValueInitCases.joined(separator: "\n"))
                default: return nil
                }
            }

            #if Inlinable
            @inlinable
            #endif
            public var rawValue: String {
                switch self {
        \(rawValueCases.joined(separator: "\n"))
                }
            }
        }
        """
    }
}


// MARK: Standard
extension HTTPRequestMethods {
    private static var standard: [(String, String)] {
        [
            ("connect", "CONNECT"),
            ("delete", "DELETE"),
            ("`get`", "GET"),
            ("head", "HEAD"),
            ("options", "OPTIONS"),
            ("patch", "PATCH"),
            ("post", "POST"),
            ("put", "PUT"),
            ("trace", "TRACE"),

            ("acl", "ACL"),
            ("baselineControl", "BASELINE-CONTROL"),
            ("cancel", "CANCEL"),
            ("checkin", "CHECKIN"),
            ("checkout", "CHECKOUT"),
            ("copy", "COPY"),
            ("label", "LABEL"),
            ("link", "LINK"),
            ("lock", "LOCK"),
            ("merge", "MERGE"),
            ("message", "MESSAGE"),
            ("mkactivity", "MKACTIVITY"),
            ("mkcol", "MKCOL"),
            ("mkredirectref", "MKREDIRECTREF"),
            ("mkworkspace", "MKWORKSPACE"),
            ("move", "MOVE"),
            ("notify", "NOTIFY"),
            ("orderpatch", "ORDERPATCH"),
            ("propfind", "PROPFIND"),
            ("proppatch", "PROPPATCH"),
            ("report", "REPORT"),
            ("subscribe", "SUBSCRIBE"),
            ("uncheckout", "UNCHECKOUT"),
            ("unlink", "UNLINK"),
            ("unlock", "UNLOCK"),
            ("unsubscribe", "UNSUBSCRIBE"),
            ("update", "UPDATE"),
            ("updateredirectref", "UPDATEREDIRECTREF"),
            ("versionControl", "VERSION-CONTROL")
        ]
    }
}

// MARK: Non-standard
extension HTTPRequestMethods {
    private static var nonStandard: [(String, String)] {
        [
            ("announce", "ANNOUNCE"),
            ("append", "APPEND"),
            ("authenticate", "AUTHENTICATE"),
            ("authorization", "AUTHORIZATION"),
            ("backup", "BACKUP"),
            ("batch", "BATCH"),
            ("bind", "BIND"),
            ("check", "CHECK"),
            ("clear", "CLEAR"),
            ("clone", "CLONE"),
            ("close", "CLOSE"),
            ("complete", "COMPLETE"),
            ("convert", "CONVERT"),
            ("curate", "CURATE"),
            ("deactivate", "DEACTIVATE"),
            ("deplete", "DEPLETE"),
            ("deploy", "DEPLOY"),
            ("deregister", "DEREGISTER"),
            ("describe", "DESCRIBE"),
            ("deliver", "DELIVER"),
            ("disable", "DISABLE"),
            ("dispatch", "DISPATCH"),
            ("draft", "DRAFT"),
            ("dump", "DUMP"),
            ("enable", "ENABLE"),
            ("establish", "ESTABLISH"),
            ("execute", "EXECUTE"),
            ("expand", "EXPAND"),
            ("fetch", "FETCH"),
            ("finalize", "FINALIZE"),
            ("force", "FORCE"),
            ("freeze", "FREEZE"),
            ("handshake", "HANDSHAKE"),
            ("hold", "HOLD"),
            ("info", "INFO"),
            ("initialize", "INITIALIZE"),
            ("install", "INSTALL"),
            ("invite", "INVITE"),
            ("join", "JOIN"),
            ("migrate", "MIGRATE"),
            ("mkcalendar", "MKCALENDAR"),
            ("msearch", "MSEARCH"),
            ("notifyall", "NOTIFYALL"),
            ("notifyFile", "NOTIFY-FILE"),
            ("`open`", "OPEN"),
            ("outbox", "OUTBOX"),
            ("partial", "PARTIAL"),
            ("partialUpdate", "PARTIAL-UPDATE"),
            ("patchForm", "PATCH-FORM"),
            ("patchMultipart", "PATCH-MULTIPART"),
            ("pause", "PAUSE"),
            ("ping", "PING"),
            ("pingAck", "PING-ACK"),
            ("play", "PLAY"),
            ("poll", "POLL"),
            ("prepare", "PREPARE"),
            ("provision", "PROVISION"),
            ("purge", "PURGE"),
            ("query", "QUERY"),
            ("rebind", "REBIND"),
            ("redirect", "REDIRECT"),
            ("record", "RECORD"),
            ("recover", "RECOVER"),
            ("refer", "REFER"),
            ("register", "REGISTER"),
            ("reject", "REJECT"),
            ("reload", "RELOAD"),
            ("replicate", "REPLICATE"),
            ("reserve", "RESERVE"),
            ("reset", "RESET"),
            ("restart", "RESTART"),
            ("restore", "RESTORE"),
            ("resume", "RESUME"),
            ("retry", "RETRY"),
            ("retryCount", "RETRY-COUNT"),
            ("rewind", "REWIND"),
            ("rollback", "ROLLBACK"),
            ("rotate", "ROTATE"),
            ("search", "SEARCH"),
            ("searchall", "SEARCHALL"),
            ("setup", "SETUP"),
            ("shutdown", "SHUTDOWN"),
            ("skip", "SKIP"),
            ("source", "SOURCE"),
            ("split", "SPLIT"),
            ("stash", "STASH"),
            ("stop", "STOP"),
            ("submit", "SUBMIT"),
            ("suspend", "SUSPEND"),
            ("sync", "SYNC"),
            ("syncstate", "SYNCSTATE"),
            ("teardown", "TEARDOWN"),
            ("thaw", "THAW"),
            ("ticket", "TICKET"),
            ("unbind", "UNBIND"),
            ("unblock", "UNBLOCK"),
            ("undeploy", "UNDEPLOY"),
            ("uninstall", "UNINSTALL"),
            ("upgrade", "UPGRADE"),
            ("unset", "UNSET"),
            ("validate", "VALIDATE"),
            ("verify", "VERIFY")
        ]
    }
}