//
//  Utilities.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import HTTPTypes

@inlinable package func cerror() -> String { String(cString: strerror(errno)) + " (errno=\(errno))" }

// MARK: RouterGroup
public struct RouterGroup : Sendable {
    public let method:HTTPRequest.Method?
    public let path:String
    public let routers:[Router]

    public init(
        method: HTTPRequest.Method? = nil,
        path: String,
        routers: [Router]
    ) {
        self.method = method
        self.path = path
        self.routers = routers
    }
}

// MARK: Router
public struct Router : Sendable {
    public let staticResponses:[StackString32:RouteResponseProtocol]

    public init(staticResponses: [StackString32:RouteResponseProtocol]) {
        self.staticResponses = staticResponses
    }
}

public enum RouterReturnType : String {
    case staticString, uint8Array, uint16Array
    case data
    case unsafeBufferPointer
}

// MARK: Middleware
public protocol MiddlewareProtocol : Hashable {
    var appliesToMethods : Set<HTTPRequest.Method> { get }
    var appliesToStatuses : Set<HTTPResponse.Status> { get }
    var appliesToContentTypes : Set<HTTPField.ContentType> { get }

    var appliesStatus : HTTPResponse.Status? { get }
    var appliesHeaders : [String:String] { get }
}
public protocol DynamicMiddlewareProtocol : MiddlewareProtocol {
}
public struct StaticMiddleware : MiddlewareProtocol {
    public let appliesToMethods:Set<HTTPRequest.Method>
    public let appliesToStatuses:Set<HTTPResponse.Status>
    public let appliesToContentTypes:Set<HTTPField.ContentType>

    public let appliesStatus:HTTPResponse.Status?
    public let appliesHeaders:[String:String]

    public init(
        appliesToMethods: Set<HTTPRequest.Method> = [],
        appliesToStatuses: Set<HTTPResponse.Status> = [],
        appliesToContentTypes: Set<HTTPField.ContentType> = [],
        appliesStatus: HTTPResponse.Status? = nil,
        appliesHeaders: [String:String] = [:]
    ) {
        self.appliesToMethods = appliesToMethods
        self.appliesToStatuses = appliesToStatuses
        self.appliesToContentTypes = appliesToContentTypes
        self.appliesStatus = appliesStatus
        self.appliesHeaders = appliesHeaders
    }
}

// MARK: RouteProtocol
public protocol RouteProtocol {
    static var routeType : RouteType { get }
    var result : RouteResult { get }
}

public enum RouteType {
    case `static`, dynamic
}

// MARK: RouteResult
public enum RouteResult {
    case string(String)
    case bytes([UInt8])

    var count : Int {
        switch self {
            case .string(let string): return string.utf8.count
            case .bytes(let bytes): return bytes.count
        }
    }
}

// MARK: StaticRoute
public struct StaticRoute : RouteProtocol {
    public static let routeType:RouteType = .static
    
    public let method:HTTPRequest.Method
    public package(set) var path:String
    public let status:HTTPResponse.Status?
    public let contentType:HTTPField.ContentType, charset:String?
    public let result:RouteResult

    public init(
        method: HTTPRequest.Method,
        path: String,
        status: HTTPResponse.Status? = nil,
        contentType: HTTPField.ContentType,
        charset: String? = nil,
        result: RouteResult
    ) {
        self.method = method
        self.path = path
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.result = result
    }

    package func response(version: String, middleware: [any MiddlewareProtocol]) -> String {
        var response_status:HTTPResponse.Status? = status
        var headers:[String:String] = [:]
        headers[HTTPField.Name.contentType.rawName] = contentType.rawValue + (charset != nil ? "; charset=" + charset! : "")
        for middleware in middleware {
            if middleware.appliesToMethods.contains(method) && middleware.appliesToContentTypes.contains(contentType)
                    && (response_status != nil ? middleware.appliesToStatuses.contains(response_status!) : true) {
                if let applied_status:HTTPResponse.Status = middleware.appliesStatus {
                    response_status = applied_status
                }
                for (header, value) in middleware.appliesHeaders {
                    headers[header] = value
                }
            }
        }
        let result_string:String
        switch result {
            case .string(let string):
                result_string = string
                break
            case .bytes(let bytes):
                result_string = bytes.map({ "\($0)" }).joined()
                break
        }
        var string:String = version + " \(response_status ?? HTTPResponse.Status.notImplemented)\\r\\n"
        for (header, value) in headers {
            string += header + ": " + value + "\\r\\n"
        }
        string += HTTPField.Name.contentLength.rawName + ": \(result.count)"
        return string + "\\r\\n\\r\\n" + result_string
    }
}

// MARK: Request
public struct Request : ~Copyable {
    public let method:HTTPRequest.Method
    public let path:StackString64
    public let headers:[HTTPField.Name:String]
}

// MARK: HTTPField.ContentType
public extension HTTPField {
    enum ContentType : Hashable, CustomStringConvertible {
        case aac
        case abw
        case apng
        case arc
        case avif
        case avi
        case azw
        case bin
        case bmp
        case bz
        case bz2
        case cda
        case csh
        case css
        case csv
        case doc
        case docx
        case eot
        case epub
        case gz
        case gif
        case htm, html
        case ico
        case ics
        case jar
        case jpeg, jpg
        case js, javascript
        case json
        case jsonld
        case mid, midi
        case mjs
        case mp3
        case mp4
        case mpeg
        case mpkg
        case odp
        case ods
        case odt
        case oga
        case ogv
        case ogx
        case opus
        case otf
        case png
        case pdf
        case php
        case ppt
        case pptx
        case rar
        case rtf
        case sh
        case svg
        case tar
        case tif, tiff
        case ts
        case ttf
        case txt
        case vsd
        case wav
        case weba
        case webm
        case webp
        case woff
        case woff2
        case xhtml
        case xls
        case xlsx
        case xml
        case xul
        case zip
        case _3gp
        case _3g2
        case _7z
        case custom(String)

        public var description : String { rawValue }

        public init(rawValue: String) {
            self = .custom(rawValue)
        }

        public var rawValue : String {
            switch self {
            case .aac: return "audio/aac"
            case .abw: return "application/x-abiword"
            case .apng: return "image/apng"
            case .arc: return "application/x-freearc"
            case .avif: return "image/avif"
            case .avi: return "video/x-msvideo"
            case .azw: return "application/vnd.amazon.ebook"
            case .bin: return "application/octet-stream"
            case .bmp: return "image/bmp"
            case .bz: return "application/x-bzip"
            case .bz2: return "application/x-bzip2"
            case .cda: return "application/x-cdf"
            case .csh: return "application/x-csh"
            case .css: return "text/css"
            case .csv: return "text/csv"
            case .doc: return "application/msword"
            case .docx: return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            case .eot: return "application/vnd.ms-fontobject"
            case .epub: return "application/epub+zip"
            case .gz: return "application/gzip"
            case .gif: return "image/gif"
            case .htm, .html: return "text/html"
            case .ico: return "image/vnd.microsoft.icon"
            case .ics: return "text/calendar"
            case .jar: return "application/java-archive"
            case .jpeg, .jpg: return "image/jpeg"
            case .js, .javascript: return "text/javascript"
            case .json: return "application/json"
            case .jsonld: return "application/ld+json"
            case .mid, .midi: return "audio/midi"
            case .mjs: return "text/javascript"
            case .mp3: return "audio/mpeg"
            case .mp4: return "video/mp4"
            case .mpeg: return "video/mpeg"
            case .mpkg: return "application/vnd.apple.installer+xml"
            case .odp: return "application/vnd.oasis.opendocument.presentation"
            case .ods: return "application/vnd.oasis.opendocument.spreadsheet"
            case .odt: return "application/vnd.oasis.opendocument.text"
            case .oga: return "audio/ogg"
            case .ogv: return "video/ogg"
            case .ogx: return "application/ogg"
            case .opus: return "audio/ogg"
            case .otf: return "font/otf"
            case .png: return "image/png"
            case .pdf: return "application/pdf"
            case .php: return "application/x-httpd-php"
            case .ppt: return "application/vnd.ms-powerpoint"
            case .pptx: return "application/vnd.openxlformats-officedocument.presentationml.presentation"
            case .rar: return "application/vnd.rar"
            case .rtf: return "application/rtf"
            case .sh: return "application/x-sh"
            case .svg: return "image/svg+xml"
            case .tar: return "application/x-tar"
            case .tif, .tiff: return "image/tiff"
            case .ts: return "video/mp2t"
            case .ttf: return "font/ttf"
            case .txt: return "text/plain"
            case .vsd: return "application/vnd.visio"
            case .wav: return "audio/wav"
            case .weba: return "audio/webm"
            case .webm: return "video/webm"
            case .webp: return "image/webp"
            case .woff: return "font/woff"
            case .woff2: return "font/woff2"
            case .xhtml: return "application/xhtml+xml"
            case .xls: return "application/vnd.ms-excel"
            case .xlsx: return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            case .xml: return "application/xml"
            case .xul: return "application/vnd.mozilla.xul+xml"
            case .zip: return "application/zip"
            case ._3gp: return "video/3gpp"
            case ._3g2: return "video/3gpp2"
            case ._7z: return "application/x-7z-compressed"
            case .custom(let string): return string
            }
        }
    }
}