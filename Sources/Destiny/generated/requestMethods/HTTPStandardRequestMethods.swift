
#if HTTPStandardRequestMethods

public enum HTTPStandardRequestMethod: Sendable {
    case connect
    case delete
    case get
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

    public func rawNameString() -> String {
        switch self {
        case .connect: "CONNECT"
        case .delete: "DELETE"
        case .get: "GET"
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

#if HTTPStandardRequestMethodRawValues
extension HTTPStandardRequestMethod: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "connect": self = .connect
        case "delete": self = .delete
        case "get": self = .get
        case "head": self = .head
        case "options": self = .options
        case "patch": self = .patch
        case "post": self = .post
        case "put": self = .put
        case "trace": self = .trace
        case "acl": self = .acl
        case "baselineControl": self = .baselineControl
        case "cancel": self = .cancel
        case "checkin": self = .checkin
        case "checkout": self = .checkout
        case "copy": self = .copy
        case "label": self = .label
        case "link": self = .link
        case "lock": self = .lock
        case "merge": self = .merge
        case "message": self = .message
        case "mkactivity": self = .mkactivity
        case "mkcol": self = .mkcol
        case "mkredirectref": self = .mkredirectref
        case "mkworkspace": self = .mkworkspace
        case "move": self = .move
        case "notify": self = .notify
        case "orderpatch": self = .orderpatch
        case "propfind": self = .propfind
        case "proppatch": self = .proppatch
        case "report": self = .report
        case "subscribe": self = .subscribe
        case "uncheckout": self = .uncheckout
        case "unlink": self = .unlink
        case "unlock": self = .unlock
        case "unsubscribe": self = .unsubscribe
        case "update": self = .update
        case "updateredirectref": self = .updateredirectref
        case "versionControl": self = .versionControl
        default: return nil
        }
    }

    public var rawValue: String {
        switch self {
        case .connect: "connect"
        case .delete: "delete"
        case .get: "get"
        case .head: "head"
        case .options: "options"
        case .patch: "patch"
        case .post: "post"
        case .put: "put"
        case .trace: "trace"
        case .acl: "acl"
        case .baselineControl: "baselineControl"
        case .cancel: "cancel"
        case .checkin: "checkin"
        case .checkout: "checkout"
        case .copy: "copy"
        case .label: "label"
        case .link: "link"
        case .lock: "lock"
        case .merge: "merge"
        case .message: "message"
        case .mkactivity: "mkactivity"
        case .mkcol: "mkcol"
        case .mkredirectref: "mkredirectref"
        case .mkworkspace: "mkworkspace"
        case .move: "move"
        case .notify: "notify"
        case .orderpatch: "orderpatch"
        case .propfind: "propfind"
        case .proppatch: "proppatch"
        case .report: "report"
        case .subscribe: "subscribe"
        case .uncheckout: "uncheckout"
        case .unlink: "unlink"
        case .unlock: "unlock"
        case .unsubscribe: "unsubscribe"
        case .update: "update"
        case .updateredirectref: "updateredirectref"
        case .versionControl: "versionControl"
        }
    }
}
#endif

#if canImport(DestinyBlueprint)

import DestinyBlueprint

extension HTTPStandardRequestMethod: HTTPRequestMethodProtocol {}

#endif

#endif