
/// Represents an individual path value for a route. Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
// TODO: support case sensitivity
public enum PathComponent: CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByStringLiteral, Hashable, Sendable {
    case literal(String)
    case parameter(String)
    case catchall

    public init(stringLiteral value: String) {
        if value == "**" {
            self = .catchall
        } else if value.first == ":" || value == "*" {
            var correctedValue = String(value[value.index(after: value.startIndex)...])
            Self.removeChar(char: value.first!, &correctedValue)
            self = .parameter(correctedValue)
        } else {
            var correctedValue = value
            Self.removeChar(char: ":", &correctedValue)
            self = .literal(correctedValue)
        }
    }

    static func removeChar(char: Character, _ string: inout String) {
        let startIndex = string.startIndex
        guard string.endIndex != startIndex else { return }
        var i = string.index(before: string.endIndex)
        while i > startIndex {
            if string[i] == char {
                string.remove(at: i)
            }
            string.formIndex(before: &i)
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var description: String {
        "\"\(slug)\""
    }

    public var debugDescription: String {
        switch self {
        case .literal(let s): "PathComponent.literal(\"\(s)\")"
        case .parameter(let s): "PathComponent.parameter(\"\(s)\")"
        case .catchall: "PathComponent.catchall"
        }
    }

    /// Whether or not this component is a literal.
    #if Inlinable
    @inlinable
    #endif
    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    /// Whether or not this component is a parameter.
    #if Inlinable
    @inlinable
    #endif
    public var isParameter: Bool {
        switch self {
        case .literal:   false
        case .parameter: true
        case .catchall:  true
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter.
    /// Used to determine where parameters are located in a route's path at compile time.
    #if Inlinable
    @inlinable
    #endif
    public var slug: String {
        switch self {
        case .literal(let value):   value
        case .parameter(let value): ":" + value
        case .catchall: "**"
        }
    }

    /// String representation of this component where the delimiter is omitted (only the name of the path is present).
    #if Inlinable
    @inlinable
    #endif
    public var value: String {
        switch self {
        case .literal(let value):   value
        case .parameter(let value): value
        case .catchall:             ""
        }
    }
}