
#if Compression

import Destiny
import SwiftCompressionUtilities
import SwiftSyntax
import SwiftSyntaxMacros

extension CompressionSettings {
    public static func parse(
        context: some MacroExpansionContext,
        expr: some ExprSyntaxProtocol
    ) -> Self {
        guard let function = expr.functionCall else {
            return Self(enabled: false, compressOnlyIfResultIsSmaller: false, supportedCompressionAlgorithms: [:])
        }
        var settings = Self()
        var enabled = true
        var compressOnlyIfResultIsSmaller = true
        for arg in function.arguments {
            switch arg.label?.text {
            case "enabled":
                enabled = arg.expression.booleanIsTrue
            case "compressOnlyIfResultIsSmaller":
                compressOnlyIfResultIsSmaller = arg.expression.booleanIsTrue
            case "supportedCompressionAlgorithms":
                settings.supportedCompressionAlgorithms = [:]
                guard let dict = arg.expression.dictionary else { continue }
                switch dict.content {
                case .elements(let elements):
                    for e in elements {
                        guard let algorithm = CompressionAlgorithm.parse(e.key) else { continue }
                        settings.supportedCompressionAlgorithms[algorithm] = CompressorSettings.parse(context: context, expr: e.value)
                    }
                default:
                    break
                }
            default:
                break
            }
        }
        settings.flags = Self.Flags.pack(enabled: enabled, compressOnlyIfResultIsSmaller: compressOnlyIfResultIsSmaller)
        return settings
    }
}

#endif