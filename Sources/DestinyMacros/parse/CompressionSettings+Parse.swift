
#if Compression

import Destiny
import SwiftCompression
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
        var enabled = true
        var compressOnlyIfResultIsSmaller = true
        var supportedCompressionAlgorithms = [CompressionAlgorithm:CompressorSettings]()
        for arg in function.arguments {
            switch arg.label?.text {
            case "enabled":
                enabled = arg.expression.booleanIsTrue
            case "compressOnlyIfResultIsSmaller":
                compressOnlyIfResultIsSmaller = arg.expression.booleanIsTrue
            case "supportedCompressionAlgorithms":
                guard let dict = arg.expression.dictionary else { continue }
                let _:DictionaryElementListSyntax
                switch dict.content {
                case .elements(let elements):
                    for e in elements {
                        guard let algorithm = CompressionAlgorithm.parse(e.key) else { continue }
                        supportedCompressionAlgorithms[algorithm] = CompressorSettings.parse(context: context, expr: e.value)
                    }
                default:
                    break
                }
                break
            default:
                break
            }
        }
        return Self(
            enabled: enabled,
            compressOnlyIfResultIsSmaller: compressOnlyIfResultIsSmaller,
            supportedCompressionAlgorithms: supportedCompressionAlgorithms
        )
    }
}

#endif