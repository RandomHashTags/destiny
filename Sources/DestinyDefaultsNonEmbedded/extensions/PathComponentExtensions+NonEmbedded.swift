
import DestinyBlueprint

// MARK: CustomStringConvertible
extension PathComponent: CustomStringConvertible {
    #if Inlinable
    @inlinable
    #endif
    public var description: String {
        "\"\(slug)\""
    }
}

// MARK: ExpressibleByStringLiteral
extension PathComponent: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = Self.fromString(value)
    }
}