
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
        } else if let partialMatchStartIndex = value.firstIndex(of: "{"), let partialMatchEndIndex = value.firstIndex(of: "}") {
            let parameterName = String(value[value.index(after: partialMatchStartIndex)..<partialMatchEndIndex])
            let firstComponent:PathComponent
            let secondComponent:PathComponent
            if partialMatchStartIndex == value.startIndex {
                firstComponent = .parameter(parameterName)
            } else {
                let before = String(value[value.startIndex..<partialMatchStartIndex])
                firstComponent = .literal(before)
            }
            if partialMatchEndIndex == value.index(before: value.endIndex) {
                secondComponent = .parameter(parameterName)
            } else {
                let targetComponent = Self(stringLiteral: String(value[value.index(after: partialMatchEndIndex)...]))
                if firstComponent.isParameter {
                    secondComponent = targetComponent
                } else {
                    secondComponent = .components(.parameter(parameterName), targetComponent)
                }
            }
            self = .components(firstComponent, secondComponent)
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