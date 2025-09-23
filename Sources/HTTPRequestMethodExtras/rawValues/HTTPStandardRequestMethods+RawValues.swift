
import DestinyDefaults

extension HTTPStandardRequestMethod: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: String) {
        switch rawValue {
        case "connect": self = .connect
        case "delete": self = .delete
        case "`get`", "get": self = .`get`
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

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .connect: "connect"
        case .delete: "delete"
        case .`get`: "get"
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