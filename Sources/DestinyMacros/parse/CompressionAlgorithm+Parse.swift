
#if Compression

import BrotliShim
import SwiftCompressionUtilities
import SwiftSyntax
import ZlibShim

// MARK: SwiftSyntax
extension CompressionAlgorithm {
    public static func parse(
        _ expr: some ExprSyntaxProtocol
    ) -> Self? {
        let key:String
        guard let function = expr.functionCall else { return nil }
        if let string = function.calledExpression.memberAccess?.declName.baseName.text {
            key = string
        } else {
            return nil
        }
        let arguments = function.arguments
        switch key {
        /*case "aac": self = .aac
        case "mp3": self = .mp3

        case "arithmetic": self = .arithmetic

        case "bwt": self = .bwt
        case "deflate": self = .deflate
        case "huffmanCoding": self = .huffman(rootNode: nil)
        case "json": self = .json
        case "lz4": self = .lz4*/
        case "brotli":
            var quality:Int32 = BROTLI_DEFAULT_QUALITY
            var windowSize:Int32 = BROTLI_DEFAULT_WINDOW
            var mode:UInt32 = BROTLI_MODE_GENERIC.rawValue
            for child in arguments {
                switch child.label?.text {
                case "quality": quality = Int32(child.expression.integerLiteral!.literal.text) ?? 0
                case "windowSize": windowSize = Int32(child.expression.integerLiteral!.literal.text) ?? 0
                case "mode": mode = UInt32(child.expression.integerLiteral!.literal.text) ?? 0
                default: break
                }
            }
            return .brotli(quality: quality, windowSize: windowSize, mode: mode)
        case "lz77":
            var windowSize = 0
            var bufferSize = 0
            var offsetBitWidth = 0
            for child in arguments {
                switch child.label?.text {
                case "windowSize": windowSize = Int(child.expression.integerLiteral!.literal.text) ?? 0
                case "bufferSize": bufferSize = Int(child.expression.integerLiteral!.literal.text) ?? 0
                case "offsetBitWidth": offsetBitWidth = Int(child.expression.integerLiteral!.literal.text) ?? 0
                default: break
                }
            }
            return .lz77(windowSize: windowSize, bufferSize: bufferSize, offsetBitWidth: offsetBitWidth)
        /*case "lz78": self = .lz78
        case "lzw": self = .lzw
        case "mtf": self = .mtf*/

        case "gzip":
            var bufferSize = 1024
            var level = Z_DEFAULT_COMPRESSION
            var memLevel:Int32 = 8
            var strategy = Z_DEFAULT_STRATEGY
            for child in arguments {
                switch child.label?.text {
                case "bufferSize": bufferSize = Int(child.expression.integerLiteral!.literal.text) ?? 0
                case "level": level = Int32(child.expression.integerLiteral!.literal.text) ?? 0
                case "memLevel": memLevel = Int32(child.expression.integerLiteral!.literal.text) ?? 0
                case "strategy": strategy = Int32(child.expression.integerLiteral!.literal.text) ?? 0
                default:
                    break
                }
            }
            return .gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)

        case "runLengthEncoding":
            var minRun = 0
            var alwaysIncludeRunCount:Bool = false
            for child in arguments {
                switch child.label?.text {
                case "minRun": minRun = Int(child.expression.integerLiteral!.literal.text) ?? 0
                case "alwaysIncludeRunCount": alwaysIncludeRunCount = child.expression.booleanIsTrue
                default: break
                }
            }
            return .runLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case "snappy": return CompressionAlgorithm.snappy
        /*case "snappyFramed": self = .snappyFramed
        case "zstd": self = .zstd

        case "_7z": self = ._7z
        case "bzip2": self = .bzip2
        case "gzip": self = .gzip
        case "rar": self = .rar

        case "h264": self = .h264
        case "h265": self = .h265
        case "jpeg": self = .jpeg
        case "jpeg2000": self = .jpeg2000

        case "eliasDelta": self = .eliasDelta
        case "eliasGamma": self = .eliasGamma
        case "eliasOmega": self = .eliasOmega
        case "fibonacci": self = .fibonacci*/

        case "dnaBinaryEncoding":
            var baseBits:[UInt8:UInt8] = [:]
            for child in arguments {
                switch child.label?.text {
                case "baseBits":
                    child.expression.dictionary?.content.as(DictionaryElementListSyntax.self)!.forEach({
                        baseBits[UInt8($0.key.integerLiteral!.literal.text)!] = UInt8($0.value.integerLiteral!.literal.text)
                    })
                default: break
                }
            }
            return .dnaBinaryEncoding(baseBits: baseBits)
        /*case "dnaSingleBlockEncoding": self = .dnaSingleBlockEncoding

        case "boringSSL": self = .boringSSL

        case "av1": self = .av1
        case "dirac": self = .dirac
        case "mpeg": self = .mpeg*/
        default: return nil
        }
    }
}

#endif