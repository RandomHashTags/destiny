
import DestinyBlueprint

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

// MARK: HTTPMediaType
/// All recognized media types by the IANA (https://www.iana.org/assignments/media-types/media-types.xhtml), with additional media types.
/// 
/// Additional Media Types
/// - xGoogleProtobuf & xProtobuf: Protocol Buffers (https://protobuf.dev/)
public struct HTTPMediaType: CustomDebugStringConvertible, Hashable, HTTPMediaTypeProtocol {
    public let type:String
    public let subType:String

    public init(type: String, subType: String) {
        self.type = type
        self.subType = subType
    }

    @inlinable
    public var description: String {
        return "\(type)/\(subType)"
    }

    public var debugDescription: String {
        return "HTTPMediaType(type: \"\(type)\", subType: \"\(subType)\")"
    }

    @inlinable
    static func get(_ type: String, _ subType: String) -> HTTPMediaType {
        return HTTPMediaType(type: type, subType: subType)
    }
}

// MARK: Category
extension HTTPMediaType {
    public enum Category: String, Sendable {
        case application
        case audio
        case font
        case haptics
        case image
        case message
        case model
        case multipart
        case text
        case video
    }

    @inlinable public func isType(_ category: Category) -> Bool { self.type == category.rawValue }

    @inlinable public var isApplication: Bool { isType(.application) }
    @inlinable public var isAudio: Bool { isType(.audio) }
    @inlinable public var isFont: Bool { isType(.font) }
    @inlinable public var isHaptics: Bool { isType(.haptics) }
    @inlinable public var isImage: Bool { isType(.image) }
    @inlinable public var isMessage: Bool { isType(.message) }
    @inlinable public var isModel: Bool { isType(.model) }
    @inlinable public var isMultipart: Bool { isType(.multipart) }
    @inlinable public var isText: Bool { isType(.text) }
    @inlinable public var isVideo: Bool { isType(.video) }
}

// MARK: Parse
extension HTTPMediaType {
    @inlinable
    public static func parse(memberName: String) -> Self? {
        if let v = parseApplication(memberName: memberName) { return v }
        if let v = parseFont(memberName: memberName) { return v }
        if let v = parseHaptics(memberName: memberName) { return v }
        if let v = parseImage(memberName: memberName) { return v }
        if let v = parseMessage(memberName: memberName) { return v }
        if let v = parseModel(memberName: memberName) { return v }
        if let v = parseMultipart(memberName: memberName) { return v }
        if let v = parseText(memberName: memberName) { return v }
        if let v = parseVideo(memberName: memberName) { return v }
        return nil
    }
    @inlinable
    public static func parse(fileExtension: String) -> Self? {
        if let v = parseApplication(fileExtension: fileExtension) { return v }
        if let v = parseFont(fileExtension: fileExtension) { return v }
        if let v = parseHaptics(fileExtension: fileExtension) { return v }
        if let v = parseImage(fileExtension: fileExtension) { return v }
        if let v = parseMessage(fileExtension: fileExtension) { return v }
        if let v = parseModel(fileExtension: fileExtension) { return v }
        if let v = parseMultipart(fileExtension: fileExtension) { return v }
        if let v = parseText(fileExtension: fileExtension) { return v }
        if let v = parseVideo(fileExtension: fileExtension) { return v }
        return nil
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension HTTPMediaType {
    public static func parse(context: some MacroExpansionContext, expr: ExprSyntax) -> Self? {
        if let s = expr.memberAccess?.declName.baseName.text {
            return parse(memberName: s) ?? parse(fileExtension: s)
        } else if let function = expr.functionCall {
            if let type = function.arguments.first?.expression.stringLiteral?.string {
                if let subType = function.arguments.last?.expression.stringLiteral?.string {
                    return HTTPMediaType(type: type, subType: subType)
                }
            }
        }
        return nil
    }
}

#endif