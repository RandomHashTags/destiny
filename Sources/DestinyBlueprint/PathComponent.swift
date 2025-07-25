
/// Represents an individual path value for a route. Used to determine how to handle a route responder for dynamic routes with parameters at compile time.
// TODO: support case sensitivity
public enum PathComponent: CustomStringConvertible, ExpressibleByStringLiteral, Hashable, Sendable {
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

    @inlinable
    public var description: String {
        "\"" + slug + "\""
    }

    /// - Returns: Whether or not this component is a parameter.
    @inlinable
    public var isParameter: Bool {
        switch self {
        case .literal:   false
        case .parameter: true
        case .catchall:  true
        }
    }

    /// String representation of this component including the delimiter, if it is a parameter.
    /// Used to determine where parameters are located in a route's path at compile time.
    @inlinable
    public var slug: String {
        switch self {
        case .literal(let value):   value
        case .parameter(let value): ":" + value
        case .catchall: "**"
        }
    }

    /// - Returns: A string representation of this component where the delimiter is omitted (only the name of the path is present).
    @inlinable
    public var value: String {
        switch self {
        case .literal(let value):   value
        case .parameter(let value): value
        case .catchall:             ""
        }
    }
}

#if canImport(SwiftDiagnostics) && canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: SwiftSyntax
extension PathComponent {
    public static func parseArray(context: some MacroExpansionContext, _ expr: ExprSyntax) -> [String] {
        var array = [String]()
        if let literal = expr.stringLiteral?.string.split(separator: "/") {
            for substring in literal {
                if substring.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expr)
                    return []
                }
                array.append(String(substring))
            }
        } else if let arrayElements = expr.array?.elements {
            for element in arrayElements {
                guard let string = element.expression.stringLiteral?.string else { return [] }
                if string.contains(" ") {
                    Diagnostic.spacesNotAllowedInRoutePath(context: context, node: element.expression)
                    return []
                }
                array.append(string)
            }
        }
        return array
    }
    public static func parseArray(context: some MacroExpansionContext, _ expr: ExprSyntax) -> [PathComponent] {
        return expr.array?.elements.compactMap({ PathComponent(context: context, expression: $0.expression) }) ?? []
    }

    public init?(context: some MacroExpansionContext, expression: ExprSyntax) {
        guard let string = expression.stringLiteral?.string ?? expression.functionCall?.calledExpression.memberAccess?.declName.baseName.text else { return nil }
        if string.contains(" ") {
            Diagnostic.spacesNotAllowedInRoutePath(context: context, node: expression)
            return nil
        }
        self = .init(stringLiteral: string)
    }
}
#endif