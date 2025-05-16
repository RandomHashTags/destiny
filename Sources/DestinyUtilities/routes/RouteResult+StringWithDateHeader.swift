//
//  RouteResult+String.swift
//
//
//  Created by Evan Anderson on 5/15/25.
//

import DestinyBlueprint

extension RouteResult {
    @inlinable
    public static func stringWithDateHeader(_ value: Swift.String) -> StringWithDateHeader {
        Self.StringWithDateHeader(value)
    }

    public struct StringWithDateHeader: RouteResultProtocol {
        public var value:Swift.String

        @inlinable
        public init(_ value: Swift.String) {
            self.value = value
        }

        public var id: Swift.String {
            "stringWithDateHeader"
        }

        public var debugDescription: Swift.String {
            "RouteResult.stringWithDateHeader(\"\(value)\")"
        }

        public var responderDebugDescription: Swift.String {
            "RouteResponses.StringWithDateHeader(\"\(value)\")"
        }

        public func responderDebugDescription(_ input: Swift.String) -> Swift.String {
            Self(input).responderDebugDescription
        }

        public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> Swift.String {
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }

        @inlinable
        public var count: Int {
            value.utf8.count
        }
        
        @inlinable
        public func string() -> Swift.String {
            value
        }

        @inlinable
        public func bytes() -> [UInt8] {
            [UInt8](value.utf8)
        }

        @inlinable
        public func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
            try InlineVLArray<UInt8>.create(string: value, closure)
        }
    }
}