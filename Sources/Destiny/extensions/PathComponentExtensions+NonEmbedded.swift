
#if NonEmbedded

// MARK: CustomStringConvertible
extension PathComponent: CustomStringConvertible {
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

#endif