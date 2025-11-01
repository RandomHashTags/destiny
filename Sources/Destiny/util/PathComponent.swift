
/// Represents an individual path value for a route.
/// Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
public enum PathComponent: Equatable, Sendable { // TODO: remove `Equatable` conformance or use under a package trait
    /// Path component that matches the given `String` exactly.
    case literal(String)

    /// Path component that matches a case-insensitive variable-length input.
    case parameter(parameterName: String)

    /// Path component that matches everything.
    case catchall

    /// Path component that enables multiple components to be joined sequentially.
    indirect case components(PathComponent, PathComponent?)

    /// Whether or not this component is a literal.
    public var isLiteral: Bool {
        guard case .literal = self else { return false }
        return true
    }

    /// Whether or not this component does any route path matching.
    public var isParameter: Bool {
        switch self {
        case .literal:   false
        case .parameter: true
        case .catchall:  true
        case .components(let l, let r): l.isParameter || (r?.isParameter ?? false)
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter.
    /// 
    /// Used to determine where parameters are located in a route's path at compile time.
    public var slug: String {
        switch self {
        case .literal(let value): value
        case .parameter(let value): ":" + value
        case .catchall: "**"
        case .components: value
        }
    }

    /// String representation of this component where the delimiter is omitted (only the name of the path is present).
    public var value: String {
        switch self {
        case .literal(let s): s
        case .parameter(let s): s
        case .catchall: ""
        case .components(let l, let r): "\(l.value)\(r?.value ?? "")"
        }
    }
}

// MARK: From string
extension PathComponent {
    public static func fromString(_ value: String) -> PathComponent {
        if value == "**" {
            return .catchall
        } else if value.first == ":" || value == "*" {
            var correctedValue = String(value[value.index(after: value.startIndex)...])
            Self.removeChar(char: value.first!, &correctedValue)
            return .parameter(parameterName: correctedValue)
        } else if let partialMatchStartIndex = value.firstIndex(of: "{"), let partialMatchEndIndex = value.firstIndex(of: "}") {
            let parameterName = String(value[value.index(after: partialMatchStartIndex)..<partialMatchEndIndex])
            let firstComponent:PathComponent
            let secondComponent:PathComponent
            if partialMatchStartIndex == value.startIndex {
                firstComponent = .parameter(parameterName: parameterName)
            } else {
                let before = String(value[value.startIndex..<partialMatchStartIndex])
                firstComponent = .literal(before)
            }
            if partialMatchEndIndex == value.index(before: value.endIndex) {
                secondComponent = .parameter(parameterName: parameterName)
            } else {
                let targetComponent = fromString(String(value[value.index(after: partialMatchEndIndex)...]))
                if firstComponent.isParameter {
                    secondComponent = targetComponent
                } else {
                    secondComponent = .components(.parameter(parameterName: parameterName), targetComponent)
                }
            }
            return .components(firstComponent, secondComponent)
        } else {
            var correctedValue = value
            Self.removeChar(char: ":", &correctedValue)
            return .literal(correctedValue)
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
}


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