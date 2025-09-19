
/// Core protocol that represents usable media/content types.
public protocol HTTPMediaTypeProtocol: CustomStringConvertible, Sendable {
    var type: String { get }
    var subType: String { get }
}

extension HTTPMediaTypeProtocol {
    #if Inlinable
    @inlinable
    #endif
    public var description: String {
        "\(type)/\(subType)"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isApplication: Bool {
        type == "application"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isAudio: Bool {
        type == "audio"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isFont: Bool {
        type == "font"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isHaptics: Bool {
        type == "haptics"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isImage: Bool {
        type == "image"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isMessage: Bool {
        type == "message"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isModel: Bool {
        type == "model"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isMultipart: Bool {
        type == "multipart"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isText: Bool {
        type == "text"
    }

    #if Inlinable
    @inlinable
    #endif
    public var isVideo: Bool {
        type == "video"
    }
}