
import SwiftSyntax

struct HTTPMediaTypes {
    static func generateSources() -> [(fileName: String, content: String)] {
        let array = [
            ("Application", applicationMediaTypes),
            ("Audio", audioMediaTypes),
            ("Font", fontMediaTypes),
            ("Haptics", hapticsMediaTypes),
            ("Image", imageMediaTypes),
            ("Message", messageMediaTypes),
            ("Model", modelMediaTypes),
            ("Multipart", multipartMediaTypes),
            ("Text", textMediaTypes),
            ("Video", videoMediaTypes)
        ]
        return array.map({
            ("HTTPMediaType\($0.0).swift", generate(type: $0.0, $0.1))
        })
    }

    private static func generate(type: String, _ values: [HTTPMediaType]) -> String {
        let enumCases = values.map({ "    case \($0.subType)" }).joined(separator: "\n")
        let fileExtensions = values.compactMap({
            guard !$0.fileExtensions.isEmpty else { return nil }
            return "        case \($0.fileExtensions.map({ "\"\($0)\"" }).joined(separator: ", ")): self = .\($0.subType)"
        }).joined(separator: "\n")
        let subtypeValues = values.map({
            var value = $0.value
            if value.isEmpty {
                value = "rawValue"
            } else {
                value = "\"\(value)\""
            }
            return "        case .\($0.subType): \(value)"
        }).joined(separator: "\n")
        return """
        import DestinyBlueprint

        public enum HTTPMediaType\(type): String, HTTPMediaTypeProtocol {
        \(enumCases)

            @inlinable
            public init?(fileExtension: some StringProtocol) {
                switch fileExtension {
        \(fileExtensions)
                default: return nil
                }
            }

            @inlinable
            public var type: String {
                "\(type.lowercased())"
            }

            @inlinable
            public var subType: String {
                switch self {
        \(subtypeValues)
                }
            }
        }
        """
    }
}