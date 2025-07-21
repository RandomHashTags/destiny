
#if canImport(SwiftCompilerPlugin) && canImport(SwiftSyntaxMacros)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DestinyMacros: CompilerPlugin {
    let providingMacros:[any Macro.Type] = [
        Router.self,
        HTTPMessage.self
    ]
}

#endif