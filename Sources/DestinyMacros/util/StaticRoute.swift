
import Destiny
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: StaticRoute
/// Default Static Route implementation where a complete HTTP Message is computed at compile time.
public struct StaticRoute: Sendable {
    public var path:[String]
    public let contentType:String?
    public internal(set) var  body:IntermediateResponseBody?

    public var method:HTTPRequestMethod
    public let status:HTTPResponseStatus.Code
    public let isCaseSensitive:Bool
    public let charset:Charset?
    public let version:HTTPVersion

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: some HTTPResponseStatus.StorageProtocol,
        contentType: String? = nil,
        charset: Charset? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.init(
            version: version,
            method: method,
            path: path,
            isCaseSensitive: isCaseSensitive,
            status: status.code,
            contentType: contentType,
            charset: charset,
            body: body
        )
    }

    public init(
        version: HTTPVersion = .v1_1,
        method: some HTTPRequestMethodProtocol,
        path: [String],
        isCaseSensitive: Bool = true,
        status: HTTPResponseStatus.Code = 501, // not implemented
        contentType: String? = nil,
        charset: Charset? = nil,
        body: IntermediateResponseBody? = nil
    ) {
        self.version = version
        self.method = .init(method)
        self.path = path
        self.isCaseSensitive = isCaseSensitive
        self.status = status
        self.contentType = contentType
        self.charset = charset
        self.body = body
    }
}

// MARK: Logic
extension StaticRoute {
    public var startLine: String {
        return "\(method.rawNameString()) /\(path.joined(separator: "/")) \(version.string)" 
    }

    public mutating func insertPath(contentsOf newElements: some Collection<String>, at i: Int) {
        path.insert(contentsOf: newElements, at: i)
    }
}

// MARK: Responder
extension StaticRoute {
    #if StaticMiddleware
    public mutating func responder(
        middleware: [StaticMiddleware]
    ) -> String? {
        return response(middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public func responder() -> String? {
        return response().string(escapeLineBreak: true)
    }
    #endif

    /// The `RouteResponderProtocol` responder for this route.
    /// 
    /// - Parameters:
    ///   - context: Macro expansion context where it was called.
    ///   - function: `FunctionCallExprSyntax` that represents this route.
    ///   - middleware: Static middleware that this route will handle.
    #if StaticMiddleware
    public mutating func responder(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax,
        middleware: [StaticMiddleware]
    ) throws(DestinyError) -> String? {
        return response(context: context, function: function, middleware: middleware).string(escapeLineBreak: true)
    }
    #else
    public mutating func responder(
        context: some MacroExpansionContext,
        function: FunctionCallExprSyntax
    ) throws(DestinyError) -> String? {
        return response(context: context, function: function).string(escapeLineBreak: true)
    }
    #endif
}