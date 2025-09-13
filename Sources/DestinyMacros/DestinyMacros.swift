
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DestinyMacros: CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
        Router.self,
        HTTPMessage.self
    ]
}

var inlinableAnnotation: String {
    "#if Inlinable\n@inlinable\n#endif"
}
var inlineAlwaysAnnotation: String {
    "#if InlineAlways\n@inline(__always)\n#endif"
}

func responderCopyableValues(isCopyable: Bool) -> (symbol: String, text: String) {
    if isCopyable {
        ("", "")
    } else {
        ("~", "NonCopyable")
    }
}