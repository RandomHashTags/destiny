
import DestinyBlueprint

#if canImport(SwiftSyntax)
import SwiftSyntax
#endif

// TODO: move to own repo?
/// HTTP request methods.
public struct HTTPRequestMethod {
    public struct Storage<let count: Int>: HTTPRequestMethodProtocol {
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.array == rhs.array
        }
        public static func == <let secondCount: Int>(lhs: Self, rhs: HTTPRequestMethod.Storage<secondCount>) -> Bool {
            guard count == secondCount else { return false }
            return lhs.array.equals(rhs.array)
        }

        public let array:InlineArray<count, UInt8>

        public init(_ array: InlineArray<count, UInt8>) {
            self.array = array
        }

        @inlinable
        public var rawName: any InlineArrayProtocol {
            array
        }

        @inlinable
        public func rawNameString() -> String {
            array.string()
        }

        public var debugDescription: String {
            "HTTPRequestMethod.Storage(\(array.debugDescription))"
        }
    }
}

/*
// MARK: Parse by literal
extension HTTPRequestMethod {
    /// - Complexity: O(1)
    @inlinable
    public static func parse(_ literal: String) -> Self? {
        switch literal {
        case "get", "GET":         .get
        case "head", "HEAD":       .head
        case "post", "POST":       .post
        case "put", "PUT":         .put
        case "delete", "DELETE":   .delete
        case "connect", "CONNECT": .connect
        case "options", "OPTIONS": .options
        case "trace", "TRACE":     .trace
        case "patch", "PATCH":     .patch
        default:                   nil
        }
    }
}
// MARK: Init by InlineArray
extension HTTPRequestMethod {
    @inlinable
    public init?(_ key: HTTPStartLine.Method) {
        switch key {
        case #inlineArray(count: 20, "GET"):     self = .get
        case #inlineArray(count: 20, "HEAD"):    self = .head
        case #inlineArray(count: 20, "POST"):    self = .post
        case #inlineArray(count: 20, "PUT"):     self = .put
        case #inlineArray(count: 20, "DELETE"):  self = .delete
        case #inlineArray(count: 20, "CONNECT"): self = .connect
        case #inlineArray(count: 20, "OPTIONS"): self = .options
        case #inlineArray(count: 20, "TRACE"):   self = .trace
        case #inlineArray(count: 20, "PATCH"):   self = .patch
        default:                                 return nil
        }
    }
}*/


extension HTTPRequestMethod {
    #httpRequestMethods([
        // MARK: Standard
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
        ("versionControl", "VERSION-CONTROL"),

        // MARK: Non-standard
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
    ])
}