
/// Core HTTP Media Type protocol that represents usable media/content types.
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
}