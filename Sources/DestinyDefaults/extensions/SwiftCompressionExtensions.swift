//
//  SwiftCompressionExtensions.swift
//
//
//  Created by Evan Anderson on 12/24/24.
//

import SwiftCompression
import SwiftSyntax

public extension CompressionTechnique {
    init?(_ expr: ExprSyntax) {
        let key:String
        if let string:String = expr.memberAccess?.declName.baseName.text ?? expr.functionCall?.calledExpression.memberAccess?.declName.baseName.text {
            key = string
        } else {
            return nil
        }
        switch key {
        case "aac": self = .aac
        case "mp3": self = .mp3

        case "arithmetic": self = .arithmetic
        case "brotli": self = .brotli

        case "bwt": self = .bwt
        case "deflate": self = .deflate
        case "huffman": self = .huffman(rootNode: nil)
        case "json": self = .json
        case "lz4": self = .lz4
        case "lz77": self = .lz77(windowSize: 0, bufferSize: 0) // TODO: finish
        case "lz78": self = .lz78
        case "lzw": self = .lzw
        case "mtf": self = .mtf
        case "runLength": self = .runLength(minRun: 0, alwaysIncludeRunCount: false) // TOOD: finish
        case "snappy": self = .snappy
        case "snappyFramed": self = .snappyFramed
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
        case "fibonacci": self = .fibonacci

        case "dnaBinaryEncoding": self = .dnaBinaryEncoding() // TODO: finish
        case "dnaSingleBlockEncoding": self = .dnaSingleBlockEncoding

        case "boringSSL": self = .boringSSL

        case "av1": self = .av1
        case "dirac": self = .dirac
        case "mpeg": self = .mpeg
        default: return nil
        }
    }

    var acceptEncodingName : String {
        switch self {
            case .brotli: return "br"
            case .huffman(let root): return "huffman"
            case .lz77(let windowSize, let bufferSize): return "lz77"
            case .lzw: return "compress"
            case .runLength(let minRun, let alwaysIncludeRunCount): return "runLength"

            case ._7z: return "7z"

            case .dnaBinaryEncoding(let baseBits): return "dnaBinaryEncoding"
            default: return rawValue
        }
    }
}