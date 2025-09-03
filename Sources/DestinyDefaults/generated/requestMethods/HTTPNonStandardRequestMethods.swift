
import DestinyBlueprint

public enum HTTPNonStandardRequestMethod: String, HTTPRequestMethodProtocol {
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
    case `open`
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
        case .`open`: "OPEN"
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