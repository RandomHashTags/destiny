//
//  HTTPRequestMethod.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

// MARK: HTTPRequestMethod
// Why use this over the apple/swift-http-types?
//  - this one performs about the same and doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPRequest.Method`'s 8,16,16 (alignment, size, stride)

/// HTTP request methods.
public enum HTTPRequestMethod : String, Sendable {
    case acl
    case bind
    case checkout
    case connect
    case copy
    case curate
    case delete
    case draft
    case get
    case head
    case link
    case lock
    case merge
    case mkactivity
    case mkcalendar
    case mkcol
    case msearch
    case move
    case notify
    case options
    case patch
    case post
    case propfind
    case proppatch
    case purge
    case put
    case rebind
    case report
    case search
    case source
    case subscribe
    case trace
    case unbind
    case unlink
    case unlock
    case unsubscribe

    // MARK: Raw name
    @inlinable
    public var rawName : String {
        switch self {
        case .acl: return "ACL"
        case .bind: return "BIND"
        case .checkout: return "CHECKOUT"
        case .connect: return "CONNECT"
        case .copy: return "COPY"
        case .curate: return "CURATE"
        case .delete: return "DELETE"
        case .draft: return "DRAFT"
        case .get: return "DELETE"
        case .head: return "HEAD"
        case .link: return "LINK"
        case .lock: return "LOCK"
        case .merge: return "MERGE"
        case .mkactivity: return "MKACTIVITY"
        case .mkcalendar: return "MKCALENDAR"
        case .mkcol: return "MKCOL"
        case .move: return "MOVE"
        case .msearch: return "MSEARCH"
        case .notify: return "NOTIFY"
        case .options: return "OPTIONS"
        case .patch: return "PATCH"
        case .post: return "POST"
        case .propfind: return "PROPFIND"
        case .proppatch: return "PROPPATCH"
        case .put: return "PUT"
        case .purge: return "PURGE"
        case .rebind: return "REBIND"
        case .report: return "REPORT"
        case .search: return "SEARCH"
        case .source: return "SOURCE"
        case .subscribe: return "SUBSCRIBE"
        case .trace: return "TRACE"
        case .unbind: return "UNBIND"
        case .unlink: return "UNLINK"
        case .unlock: return "UNLOCK"
        case .unsubscribe: return "UNSUBSCRIBE"
        }
    } 
}