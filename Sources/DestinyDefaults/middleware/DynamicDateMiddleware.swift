//
//  DynamicDateMiddleware.swift
//
//
//  Created by Evan Anderson on 1/2/25.
//

#if canImport(Foundation)
import Foundation
#endif

import DestinyUtilities
import HTTPTypes
import Logging
import ServiceLifecycle
import SwiftSyntax
import SwiftSyntaxMacros

/// Adds the `Date` header to responses for dynamic routes.
public final class DynamicDateMiddleware : DynamicMiddlewareProtocol, @unchecked Sendable {

    @usableFromInline
    var _timer:Task<Void, Never>!

    @usableFromInline
    var _date:String

    #if canImport(Foundation)
    @usableFromInline
    let _formatter:DateFormatter
    #endif

    public init() {
        _timer = nil
        _date = ""
        #if canImport(Foundation)
        _formatter = DateFormatter()
        _formatter.dateFormat = "E, d MMM yyyy HH:mm:ss"
        _formatter.timeZone = .gmt
        #endif
    }

    @inlinable
    public func load() {
        update()
        // TODO: make it update at the beginning of the second
        _timer = Task.detached(priority: .userInitiated) {
            while !Task.isCancelled && !Task.isShuttingDownGracefully {
                do {
                    try await Task.sleep(for: .seconds(1))
                    self.update()
                } catch {
                    Application.shared.logger.warning(Logger.Message(stringLiteral: "[DynamicDateMiddleware] Encountered error trying to sleep task: \(error)"))
                }
            }
        }
    }

    @usableFromInline
    func update() {
        #if canImport(Foundation)
        _date = _formatter.string(from: Date()) + " GMT"
        #else
        // TODO: support
        #endif
    }

    @inlinable
    public func handle(request: inout RequestProtocol, response: inout DynamicResponseProtocol) async throws -> Bool {
        response.headers[HTTPField.Name.date.rawName] = _date
        return true
    }

    public var debugDescription : String {
        "DynamicDateMiddleware()"
    }
}

// MARK: Parse
public extension DynamicDateMiddleware {
    static func parse(context: some MacroExpansionContext, _ function: FunctionCallExprSyntax) -> Self {
        return Self()
    }
}