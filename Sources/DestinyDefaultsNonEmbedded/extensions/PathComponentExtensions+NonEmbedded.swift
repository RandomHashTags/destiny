
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
}