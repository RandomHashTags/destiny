
/// Represents an individual path value for a route.
/// Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
// TODO: support case sensitivity
public enum PathComponent: Equatable, Sendable {
    case literal(String)
    case parameter(String)
    case catchall

    indirect case components(PathComponent, PathComponent?)

    /// Whether or not this component is a literal.
    #if Inlinable
    @inlinable
    #endif
    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    /// Whether or not this component does any route path matching.
    #if Inlinable
    @inlinable
    #endif
    public var isParameter: Bool {
        switch self {
        case .literal:   false
        case .parameter: true
        case .catchall:  true
        case .components(let l, let r): l.isParameter || (r?.isParameter ?? false)
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter.
    /// Used to determine where parameters are located in a route's path at compile time.
    #if Inlinable
    @inlinable
    #endif
    public var slug: String {
        switch self {
        case .literal(let value): value
        case .parameter(let value): ":" + value
        case .catchall: "**"
        case .components: value
        }
    }

    /// String representation of this component where the delimiter is omitted (only the name of the path is present).
    #if Inlinable
    @inlinable
    #endif
    public var value: String {
        switch self {
        case .literal(let s): s
        case .parameter(let s): s
        case .catchall: ""
        case .components(let l, let r): "\(l.value)\(r?.value ?? "")"
        }
    }
}