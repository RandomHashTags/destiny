
#if Compression

import SwiftCompression

extension CompressionAlgorithm {
    public var acceptEncodingName: String {
        switch self {
        case .brotli: "br"
        case .huffmanCoding: "huffman"
        case .lzw: "compress"

        case .gzip: "gzip"

        case ._7z: "7z"
        default: rawValue
        }
    }
}

#endif