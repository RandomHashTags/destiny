//
//  SwiftCompressionExtensions.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import SwiftCompression
import SwiftSyntax

extension CompressionAlgorithm {
    public var acceptEncodingName : String {
        switch self {
            case .brotli: return "br"
            case .huffmanCoding: return "huffman"
            case .lzw: return "compress"

            case ._7z: return "7z"
            default: return rawValue
        }
    }
}

#if canImport(SwiftSyntax)
// MARK: SwiftSyntax
extension CompressionAlgorithm {
    public static func parse(_ expr: ExprSyntax) -> Self? {
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
        case "brotli": self = .brotli

        case "bwt": self = .bwt
        case "deflate": self = .deflate
        case "huffmanCoding": self = .huffman(rootNode: nil)
        case "json": self = .json
        case "lz4": self = .lz4*/
        case "lz77":
            var windowSize:Int = 0, bufferSize:Int = 0, offsetBitWidth:Int = 0
            for child in arguments {
                switch child.label?.text {
                case "windowSize": windowSize = Int(child.expression.integerLiteral!.literal.text)!
                case "bufferSize": bufferSize = Int(child.expression.integerLiteral!.literal.text)!
                case "offsetBitWidth": offsetBitWidth = Int(child.expression.integerLiteral!.literal.text)!
                default: break
                }
            }
            return .lz77(windowSize: windowSize, bufferSize: bufferSize, offsetBitWidth: offsetBitWidth)
        /*case "lz78": self = .lz78
        case "lzw": self = .lzw
        case "mtf": self = .mtf*/
        case "runLengthEncoding":
            var minRun:Int = 0, alwaysIncludeRunCount:Bool = false
            for child in arguments {
                switch child.label?.text {
                case "minRun": minRun = Int(child.expression.integerLiteral!.literal.text)!
                case "alwaysIncludeRunCount": alwaysIncludeRunCount = child.expression.booleanLiteral!.isTrue
                default: break
                }
            }
            return .runLengthEncoding(minRun: minRun, alwaysIncludeRunCount: alwaysIncludeRunCount)
        case "snappy": return CompressionAlgorithm.snappy(windowSize: 32_000)
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
            var baseBits:[UInt8:[Bool]] = [:]
            for child in arguments {
                switch child.label?.text {
                case "baseBits":
                    child.expression.dictionary?.content.as(DictionaryElementListSyntax.self)!.forEach({
                        baseBits[UInt8($0.key.integerLiteral!.literal.text)!] = $0.value.array!.elements.map({ $0.expression.booleanLiteral!.isTrue })
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