
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

    public init(_ type: some HTTPMediaTypeProtocol) {
        self.type = type.type
        self.subType = type.subType
    }

    public var debugDescription: String {
        return "HTTPMediaType(type: \"\(type)\", subType: \"\(subType)\")"
    }

    @inlinable
    package static func get(_ type: String, _ subType: String) -> HTTPMediaType {
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