
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

    #if Inlinable
    @inlinable
    #endif
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

    #if Inlinable
    @inlinable
    #endif
    public func isType(_ category: Category) -> Bool {
        self.type == category.rawValue
    }

    #if Inlinable
    @inlinable
    #endif
    public var isApplication: Bool {
        isType(.application)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isAudio: Bool {
        isType(.audio)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isFont: Bool {
        isType(.font)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isHaptics: Bool {
        isType(.haptics)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isImage: Bool {
        isType(.image)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isMessage: Bool {
        isType(.message)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isModel: Bool {
        isType(.model)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isMultipart: Bool {
        isType(.multipart)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isText: Bool {
        isType(.text)
    }

    #if Inlinable
    @inlinable
    #endif
    public var isVideo: Bool {
        isType(.video)
    }
}