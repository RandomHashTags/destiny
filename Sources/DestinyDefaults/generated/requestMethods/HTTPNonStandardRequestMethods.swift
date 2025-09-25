
#if HTTPNonStandardRequestMethods

import DestinyBlueprint

public enum HTTPNonStandardRequestMethod: HTTPRequestMethodProtocol {
    case announce
    case append
    case authenticate
    case authorization
    case backup
    case batch
    case bind
    case check
    case clear
    case clone
    case close
    case complete
    case convert
    case curate
    case deactivate
    case deplete
    case deploy
    case deregister
    case describe
    case deliver
    case disable
    case dispatch
    case draft
    case dump
    case enable
    case establish
    case execute
    case expand
    case fetch
    case finalize
    case force
    case freeze
    case handshake
    case hold
    case info
    case initialize
    case install
    case invite
    case join
    case migrate
    case mkcalendar
    case msearch
    case notifyall
    case notifyFile
    case open
    case outbox
    case partial
    case partialUpdate
    case patchForm
    case patchMultipart
    case pause
    case ping
    case pingAck
    case play
    case poll
    case prepare
    case provision
    case purge
    case query
    case rebind
    case redirect
    case record
    case recover
    case refer
    case register
    case reject
    case reload
    case replicate
    case reserve
    case reset
    case restart
    case restore
    case resume
    case retry
    case retryCount
    case rewind
    case rollback
    case rotate
    case search
    case searchall
    case setup
    case shutdown
    case skip
    case source
    case split
    case stash
    case stop
    case submit
    case suspend
    case sync
    case syncstate
    case teardown
    case thaw
    case ticket
    case unbind
    case unblock
    case undeploy
    case uninstall
    case upgrade
    case unset
    case validate
    case verify

    #if Inlinable
    @inlinable
    #endif
    public func rawNameString() -> String {
        switch self {
        case .announce: "ANNOUNCE"
        case .append: "APPEND"
        case .authenticate: "AUTHENTICATE"
        case .authorization: "AUTHORIZATION"
        case .backup: "BACKUP"
        case .batch: "BATCH"
        case .bind: "BIND"
        case .check: "CHECK"
        case .clear: "CLEAR"
        case .clone: "CLONE"
        case .close: "CLOSE"
        case .complete: "COMPLETE"
        case .convert: "CONVERT"
        case .curate: "CURATE"
        case .deactivate: "DEACTIVATE"
        case .deplete: "DEPLETE"
        case .deploy: "DEPLOY"
        case .deregister: "DEREGISTER"
        case .describe: "DESCRIBE"
        case .deliver: "DELIVER"
        case .disable: "DISABLE"
        case .dispatch: "DISPATCH"
        case .draft: "DRAFT"
        case .dump: "DUMP"
        case .enable: "ENABLE"
        case .establish: "ESTABLISH"
        case .execute: "EXECUTE"
        case .expand: "EXPAND"
        case .fetch: "FETCH"
        case .finalize: "FINALIZE"
        case .force: "FORCE"
        case .freeze: "FREEZE"
        case .handshake: "HANDSHAKE"
        case .hold: "HOLD"
        case .info: "INFO"
        case .initialize: "INITIALIZE"
        case .install: "INSTALL"
        case .invite: "INVITE"
        case .join: "JOIN"
        case .migrate: "MIGRATE"
        case .mkcalendar: "MKCALENDAR"
        case .msearch: "MSEARCH"
        case .notifyall: "NOTIFYALL"
        case .notifyFile: "NOTIFY-FILE"
        case .open: "OPEN"
        case .outbox: "OUTBOX"
        case .partial: "PARTIAL"
        case .partialUpdate: "PARTIAL-UPDATE"
        case .patchForm: "PATCH-FORM"
        case .patchMultipart: "PATCH-MULTIPART"
        case .pause: "PAUSE"
        case .ping: "PING"
        case .pingAck: "PING-ACK"
        case .play: "PLAY"
        case .poll: "POLL"
        case .prepare: "PREPARE"
        case .provision: "PROVISION"
        case .purge: "PURGE"
        case .query: "QUERY"
        case .rebind: "REBIND"
        case .redirect: "REDIRECT"
        case .record: "RECORD"
        case .recover: "RECOVER"
        case .refer: "REFER"
        case .register: "REGISTER"
        case .reject: "REJECT"
        case .reload: "RELOAD"
        case .replicate: "REPLICATE"
        case .reserve: "RESERVE"
        case .reset: "RESET"
        case .restart: "RESTART"
        case .restore: "RESTORE"
        case .resume: "RESUME"
        case .retry: "RETRY"
        case .retryCount: "RETRY-COUNT"
        case .rewind: "REWIND"
        case .rollback: "ROLLBACK"
        case .rotate: "ROTATE"
        case .search: "SEARCH"
        case .searchall: "SEARCHALL"
        case .setup: "SETUP"
        case .shutdown: "SHUTDOWN"
        case .skip: "SKIP"
        case .source: "SOURCE"
        case .split: "SPLIT"
        case .stash: "STASH"
        case .stop: "STOP"
        case .submit: "SUBMIT"
        case .suspend: "SUSPEND"
        case .sync: "SYNC"
        case .syncstate: "SYNCSTATE"
        case .teardown: "TEARDOWN"
        case .thaw: "THAW"
        case .ticket: "TICKET"
        case .unbind: "UNBIND"
        case .unblock: "UNBLOCK"
        case .undeploy: "UNDEPLOY"
        case .uninstall: "UNINSTALL"
        case .upgrade: "UPGRADE"
        case .unset: "UNSET"
        case .validate: "VALIDATE"
        case .verify: "VERIFY"
        }
    }
}

#if HTTPNonStandardRequestMethodRawValues
extension HTTPNonStandardRequestMethod: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: String) {
        switch rawValue {
        case "announce": self = .announce
        case "append": self = .append
        case "authenticate": self = .authenticate
        case "authorization": self = .authorization
        case "backup": self = .backup
        case "batch": self = .batch
        case "bind": self = .bind
        case "check": self = .check
        case "clear": self = .clear
        case "clone": self = .clone
        case "close": self = .close
        case "complete": self = .complete
        case "convert": self = .convert
        case "curate": self = .curate
        case "deactivate": self = .deactivate
        case "deplete": self = .deplete
        case "deploy": self = .deploy
        case "deregister": self = .deregister
        case "describe": self = .describe
        case "deliver": self = .deliver
        case "disable": self = .disable
        case "dispatch": self = .dispatch
        case "draft": self = .draft
        case "dump": self = .dump
        case "enable": self = .enable
        case "establish": self = .establish
        case "execute": self = .execute
        case "expand": self = .expand
        case "fetch": self = .fetch
        case "finalize": self = .finalize
        case "force": self = .force
        case "freeze": self = .freeze
        case "handshake": self = .handshake
        case "hold": self = .hold
        case "info": self = .info
        case "initialize": self = .initialize
        case "install": self = .install
        case "invite": self = .invite
        case "join": self = .join
        case "migrate": self = .migrate
        case "mkcalendar": self = .mkcalendar
        case "msearch": self = .msearch
        case "notifyall": self = .notifyall
        case "notifyFile": self = .notifyFile
        case "open": self = .open
        case "outbox": self = .outbox
        case "partial": self = .partial
        case "partialUpdate": self = .partialUpdate
        case "patchForm": self = .patchForm
        case "patchMultipart": self = .patchMultipart
        case "pause": self = .pause
        case "ping": self = .ping
        case "pingAck": self = .pingAck
        case "play": self = .play
        case "poll": self = .poll
        case "prepare": self = .prepare
        case "provision": self = .provision
        case "purge": self = .purge
        case "query": self = .query
        case "rebind": self = .rebind
        case "redirect": self = .redirect
        case "record": self = .record
        case "recover": self = .recover
        case "refer": self = .refer
        case "register": self = .register
        case "reject": self = .reject
        case "reload": self = .reload
        case "replicate": self = .replicate
        case "reserve": self = .reserve
        case "reset": self = .reset
        case "restart": self = .restart
        case "restore": self = .restore
        case "resume": self = .resume
        case "retry": self = .retry
        case "retryCount": self = .retryCount
        case "rewind": self = .rewind
        case "rollback": self = .rollback
        case "rotate": self = .rotate
        case "search": self = .search
        case "searchall": self = .searchall
        case "setup": self = .setup
        case "shutdown": self = .shutdown
        case "skip": self = .skip
        case "source": self = .source
        case "split": self = .split
        case "stash": self = .stash
        case "stop": self = .stop
        case "submit": self = .submit
        case "suspend": self = .suspend
        case "sync": self = .sync
        case "syncstate": self = .syncstate
        case "teardown": self = .teardown
        case "thaw": self = .thaw
        case "ticket": self = .ticket
        case "unbind": self = .unbind
        case "unblock": self = .unblock
        case "undeploy": self = .undeploy
        case "uninstall": self = .uninstall
        case "upgrade": self = .upgrade
        case "unset": self = .unset
        case "validate": self = .validate
        case "verify": self = .verify
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .announce: "announce"
        case .append: "append"
        case .authenticate: "authenticate"
        case .authorization: "authorization"
        case .backup: "backup"
        case .batch: "batch"
        case .bind: "bind"
        case .check: "check"
        case .clear: "clear"
        case .clone: "clone"
        case .close: "close"
        case .complete: "complete"
        case .convert: "convert"
        case .curate: "curate"
        case .deactivate: "deactivate"
        case .deplete: "deplete"
        case .deploy: "deploy"
        case .deregister: "deregister"
        case .describe: "describe"
        case .deliver: "deliver"
        case .disable: "disable"
        case .dispatch: "dispatch"
        case .draft: "draft"
        case .dump: "dump"
        case .enable: "enable"
        case .establish: "establish"
        case .execute: "execute"
        case .expand: "expand"
        case .fetch: "fetch"
        case .finalize: "finalize"
        case .force: "force"
        case .freeze: "freeze"
        case .handshake: "handshake"
        case .hold: "hold"
        case .info: "info"
        case .initialize: "initialize"
        case .install: "install"
        case .invite: "invite"
        case .join: "join"
        case .migrate: "migrate"
        case .mkcalendar: "mkcalendar"
        case .msearch: "msearch"
        case .notifyall: "notifyall"
        case .notifyFile: "notifyFile"
        case .open: "open"
        case .outbox: "outbox"
        case .partial: "partial"
        case .partialUpdate: "partialUpdate"
        case .patchForm: "patchForm"
        case .patchMultipart: "patchMultipart"
        case .pause: "pause"
        case .ping: "ping"
        case .pingAck: "pingAck"
        case .play: "play"
        case .poll: "poll"
        case .prepare: "prepare"
        case .provision: "provision"
        case .purge: "purge"
        case .query: "query"
        case .rebind: "rebind"
        case .redirect: "redirect"
        case .record: "record"
        case .recover: "recover"
        case .refer: "refer"
        case .register: "register"
        case .reject: "reject"
        case .reload: "reload"
        case .replicate: "replicate"
        case .reserve: "reserve"
        case .reset: "reset"
        case .restart: "restart"
        case .restore: "restore"
        case .resume: "resume"
        case .retry: "retry"
        case .retryCount: "retryCount"
        case .rewind: "rewind"
        case .rollback: "rollback"
        case .rotate: "rotate"
        case .search: "search"
        case .searchall: "searchall"
        case .setup: "setup"
        case .shutdown: "shutdown"
        case .skip: "skip"
        case .source: "source"
        case .split: "split"
        case .stash: "stash"
        case .stop: "stop"
        case .submit: "submit"
        case .suspend: "suspend"
        case .sync: "sync"
        case .syncstate: "syncstate"
        case .teardown: "teardown"
        case .thaw: "thaw"
        case .ticket: "ticket"
        case .unbind: "unbind"
        case .unblock: "unblock"
        case .undeploy: "undeploy"
        case .uninstall: "uninstall"
        case .upgrade: "upgrade"
        case .unset: "unset"
        case .validate: "validate"
        case .verify: "verify"
        }
    }
}
#endif

#endif