
import DestinyBlueprint

public enum HTTPStandardRequestMethod: HTTPRequestMethodProtocol {
    case connect
    case delete
    case `get`
    case head
    case options
    case patch
    case post
    case put
    case trace
    case acl
    case baselineControl
    case cancel
    case checkin
    case checkout
    case copy
    case label
    case link
    case lock
    case merge
    case message
    case mkactivity
    case mkcol
    case mkredirectref
    case mkworkspace
    case move
    case notify
    case orderpatch
    case propfind
    case proppatch
    case report
    case subscribe
    case uncheckout
    case unlink
    case unlock
    case unsubscribe
    case update
    case updateredirectref
    case versionControl

    #if Inlinable
    @inlinable
    #endif
    public func rawNameString() -> String {
        switch self {
        case .connect: "CONNECT"
        case .delete: "DELETE"
        case .`get`: "GET"
        case .head: "HEAD"
        case .options: "OPTIONS"
        case .patch: "PATCH"
        case .post: "POST"
        case .put: "PUT"
        case .trace: "TRACE"
        case .acl: "ACL"
        case .baselineControl: "BASELINE-CONTROL"
        case .cancel: "CANCEL"
        case .checkin: "CHECKIN"
        case .checkout: "CHECKOUT"
        case .copy: "COPY"
        case .label: "LABEL"
        case .link: "LINK"
        case .lock: "LOCK"
        case .merge: "MERGE"
        case .message: "MESSAGE"
        case .mkactivity: "MKACTIVITY"
        case .mkcol: "MKCOL"
        case .mkredirectref: "MKREDIRECTREF"
        case .mkworkspace: "MKWORKSPACE"
        case .move: "MOVE"
        case .notify: "NOTIFY"
        case .orderpatch: "ORDERPATCH"
        case .propfind: "PROPFIND"
        case .proppatch: "PROPPATCH"
        case .report: "REPORT"
        case .subscribe: "SUBSCRIBE"
        case .uncheckout: "UNCHECKOUT"
        case .unlink: "UNLINK"
        case .unlock: "UNLOCK"
        case .unsubscribe: "UNSUBSCRIBE"
        case .update: "UPDATE"
        case .updateredirectref: "UPDATEREDIRECTREF"
        case .versionControl: "VERSION-CONTROL"
        }
    }
}