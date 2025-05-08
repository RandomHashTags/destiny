//
//  RouteResult.swift
//
//
//  Created by Evan Anderson on 12/11/24.
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#elseif canImport(Foundation)
import Foundation
#endif

import DestinyBlueprint
import SwiftCompressionUtilities
import SwiftSyntax

// MARK: RouteResult
public enum RouteResult: CustomDebugStringConvertible, Sendable {
    case staticString(String)
    case string(String)

    /// [UInt8]
    case bytes([UInt8])

    /// [UInt16]
    case bytes16([UInt16])

    #if canImport(FoundationEssentials) || canImport(Foundation)
    case data(Data)
    #endif

    case json(Encodable & Sendable)
    case error(any Error)

    @inlinable
    public var debugDescription: String {
        switch self {
        case .staticString(let s): ".staticString(\"\(s)\")"
        case .string(let s): ".string(\"\(s)\")"
        case .bytes(let b): ".bytes(\(b))"
        case .bytes16(let b): ".bytes16(\(b))"
        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let d): ".data(Data([\(d.map({ String(describing: $0) }).joined(separator: ","))]))"
        #endif
        case .json: ".json()" // TODO: fix
        case .error: ".error()" // TODO: fix
        }
    }

    @inlinable
    public var count: Int {
        switch self {
        case .staticString(let string): string.description.utf8.count
        case .string(let string): string.utf8.count
        case .bytes(let bytes): bytes.count
        case .bytes16(let bytes): bytes.count
        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let data): data.count
        #endif
        case .json(let encodable): (try? JSONEncoder().encode(encodable).count) ?? 0
        case .error(let error): "\(error)".count
        }
    }

    @inlinable
    package func string() throws -> String {
        switch self {
        case .staticString(let string): return string.description
        case .string(let string): return string
        case .bytes(let bytes): return String.init(decoding: bytes, as: UTF8.self)
        case .bytes16(let bytes): return String.init(decoding: bytes, as: UTF16.self)
        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let data): return String.init(decoding: data, as: UTF8.self)
        #endif
        case .json(let encodable):
            do {
                #if canImport(FoundationEssentials) || canImport(Foundation)
                let data = try JSONEncoder().encode(encodable)
                return String(data: data, encoding: .utf8) ?? "{\"error\":500\",\"reason\":\"couldn't convert JSON encoded Data to UTF-8 String\"}"
                #else
                return "{}" // TODO: fix
                #endif
            } catch {
                return "{\"error\":500,\"reason\":\"\(error)\"}"
            }
        case .error(let error): return "\(error)"
        }
    }

    @inlinable
    package func bytes() throws -> [UInt8] {
        switch self {
        case .staticString(let s): return [UInt8](s.description.utf8)
        case .string(let s): return [UInt8](s.utf8)
        case .bytes(let b): return b
        case .bytes16(let b):
            var bytes:[UInt8] = []
            bytes.reserveCapacity(b.count * 2)
            for byte in b {
                bytes.append(contentsOf: byte.bytes)
            }
            return bytes
        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let d): return [UInt8](d)
        #endif
        case .json: return [] // TODO: finish
        case .error: return [] // TODO: finish
        }
    }

    @inlinable
    package func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows {
        switch self {
        case .staticString(let s):
            try InlineVLArray<UInt8>.create(string: s, closure)
        case .string(let s):
            try InlineVLArray<UInt8>.create(string: s, closure)
        case .bytes(let b):
            try InlineVLArray<UInt8>.create(collection: b, closure)
        case .bytes16(let b): // TODO: finish
            break
        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let d):
            try InlineVLArray<UInt8>.create(collection: d, closure)
        #endif
        case .json: // TODO: finish
            break
        case .error: // TODO: finish
            break
        }
    }
}

#if canImport(SwiftSyntax)
// MARK: SwiftSyntax
extension RouteResult {
    public init?(expr: ExprSyntax) {
        guard let function = expr.functionCall else { return nil }
        switch function.calledExpression.memberAccess?.declName.baseName.text {
        case "staticString":
            self = .staticString(function.arguments.first!.expression.stringLiteral!.string)
        case "string":
            self = .string(function.arguments.first!.expression.stringLiteral!.string)
        case "json":
            return nil // TODO: fix
        case "bytes":
            var bytes:[UInt8] = []
            if let expression = function.arguments.first?.expression {
                if let initCall = expression.functionCall {
                    let interp = "\(initCall.calledExpression)"
                    if (interp == "[UInt8]" || interp == "Array<UInt8>"),
                            let member = initCall.arguments.first?.expression.memberAccess,
                            let string = member.base?.stringLiteral?.string {
                        switch member.declName.baseName.text {
                        case "utf8": bytes = [UInt8](string.utf8)
                        //case "utf16": bytes = [UInt16](string.utf16)
                        default: break
                        }
                    }
                } else if let array:[UInt8] = expression.array?.elements.compactMap({
                    guard let integer = $0.expression.integerLiteral?.literal.text else { return nil }
                    return UInt8(integer)
                }) {
                    bytes = array
                }
            }
            self = .bytes(bytes)
        case "bytes16":
            var bytes:[UInt16] = []
            if let expression = function.arguments.first?.expression {
                if let initCall = expression.functionCall {
                    let interp = "\(initCall.calledExpression)"
                    if (interp == "[UInt16]" || interp == "Array<UInt16>"),
                            let member = initCall.arguments.first?.expression.memberAccess,
                            let string = member.base?.stringLiteral?.string {
                        switch member.declName.baseName.text {
                        case "utf16": bytes = [UInt16](string.utf16)
                        default: break
                        }
                    }
                } else if let array:[UInt16] = expression.array?.elements.compactMap({
                    guard let integer = $0.expression.integerLiteral?.literal.text else { return nil }
                    return UInt16(integer)
                }) {
                    bytes = array
                }
            }
            self = .bytes16(bytes)
        case "error":
            return nil // TODO: fix
        default:
            return nil
        }
    }
}
#endif

// MARK: Responder
extension RouteResult {
    public var responderDebugDescription: String {
        switch self {
        case .staticString(let s):
            "RouteResponses.StaticString(\"\(s)\")"
        case .string(let s):
            "RouteResponses.String(\"\(s)\")"
        case .bytes(let b):
            "RouteResponses.UInt8Array(\(b))"
        case .bytes16(let b):
            "RouteResponses.UInt16Array(\(b))"

        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data(let d):
            "RouteResponses.FoundationData(Data([\(d.map({ String(describing: $0) }).joined(separator: ","))]))"
        #endif

        case .json:
            "RouteResponses.StaticString(\"\")" // TODO: fix
        case .error:
            "RouteResponses.StaticString(\"\")" // TODO: fix
        }
    }

    public func responderDebugDescription(_ input: String) -> String {
        switch self {
        case .staticString: Self.staticString(input).responderDebugDescription
        case .string: Self.string(input).responderDebugDescription
        case .bytes: Self.bytes([UInt8](input.utf8)).responderDebugDescription
        case .bytes16: Self.bytes16([UInt16](input.utf16)).responderDebugDescription

        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data: Self.data(Data(input.utf8)).responderDebugDescription
        #endif

        case .json:
            "RouteResponses.StaticString(\"\")" // TODO: fix
        case .error:
            "RouteResponses.StaticString(\"\")" // TODO: fix
        }
    }

    public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
        switch self {
        case .bytes, .bytes16:
            try responderDebugDescription(input.string(escapeLineBreak: false))

        #if canImport(FoundationEssentials) || canImport(Foundation)
        case .data:
            try responderDebugDescription(input.string(escapeLineBreak: false))
        #endif

        default:
            try responderDebugDescription(input.string(escapeLineBreak: true))
        }
    }
}