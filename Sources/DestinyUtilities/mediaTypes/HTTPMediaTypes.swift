//
//  HTTPMediaType.swift
//
//
//  Created by Evan Anderson on 12/30/24.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros
#endif

/// All recognized media types by the IANA (https://www.iana.org/assignments/media-types/media-types.xhtml), with additional media types.
/// 
/// Additional Media Types
/// - xGoogleProtobuf & xProtobuf: Protocol Buffers (https://protobuf.dev/)
// MARK: HTTPMediaType
public struct HTTPMediaType : CustomDebugStringConvertible, CustomStringConvertible, Hashable, Sendable {
    public let name:String
    public let category:Category

    public init(_ category: Category, name: String) {
        self.category = category
        self.name = name
    }

    @inlinable
    public var description : String {
        return "\(category)/\(name)"
    }

    public var debugDescription : String {
        return "HTTPMediaType(.\(category), name: \"\(name)\")"
    }

    static func get(_ category: Category, name: String) -> HTTPMediaType {
        return HTTPMediaType(category, name: name)
    }
}

// MARK: Category
extension HTTPMediaType {
    public enum Category : Sendable {
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
}

// MARK: Parse
extension HTTPMediaType {
    @inlinable
    public static func parse(_ string: String) -> Self? { // TODO: fix
        /*
        if let media:Application = Application(rawValue: string) ?? Application(fileExtension: string) {
            return media.structure
        }
        if let media:Font = Font(rawValue: string) ?? Font(fileExtension: string) {
            return media.structure
        }
        if let media:Haptics = Haptics(rawValue: string) ?? Haptics(fileExtension: string) {
            return media.structure
        }
        if let media:Image = Image(rawValue: string) ?? Image(fileExtension: string) {
            return media.structure
        }
        if let media:Message = Message(rawValue: string) ?? Message(fileExtension: string) {
            return media.structure
        }
        if let media:Model = Model(rawValue: string) ?? Model(fileExtension: string) {
            return media.structure
        }
        if let media:Multipart = Multipart(rawValue: string) ?? Multipart(fileExtension: string) {
            return media.structure
        }
        if let media:Text = Text(rawValue: string) ?? Text(fileExtension: string) {
            return media.structure
        }
        if let media:Video = Video(rawValue: string) ?? Video(fileExtension: string) {
            return media.structure
        }*/
        return nil
    }
}

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
// MARK: SwiftSyntax
extension HTTPMediaType {
    public static func parse(context: some MacroExpansionContext, expr: ExprSyntax) -> Self? {
        return nil // TODO: fix
        // HTTPMediaType(debugDescription: "", httpValue: argument.expression.functionCall!.arguments.first!.expression.stringLiteral!.string)
    }
}

#endif