
// MARK: HTTPMediaType
/// All recognized media types by the IANA (https://www.iana.org/assignments/media-types/media-types.xhtml), with additional media types.
/// 
/// Additional Media Types
/// - xGoogleProtobuf & xProtobuf: Protocol Buffers (https://protobuf.dev/)
public struct HTTPMediaType: Hashable, HTTPMediaTypeProtocol {
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

    #if Inlinable
    @inlinable
    #endif
    package static func get(_ type: String, _ subType: String) -> HTTPMediaType {
        return HTTPMediaType(type: type, subType: subType)
    }
}