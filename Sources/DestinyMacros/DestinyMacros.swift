
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
    "#if Inlinable\n@inlinable\n#endif\n"
}
var inlineAlwaysAnnotation: String {
    "#if InlineAlways\n@inline(__always)\n#endif\n"
}