
#if Compression

import SwiftCompression

extension CompressionAlgorithm {
    func compress(span: Span<UInt8>) -> [UInt8]? {
        switch self {

        case .brotli(let quality, let windowSize, let mode):
            #if canImport(Brotli)
            return Brotli(quality: quality, windowSize: windowSize, mode: mode)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .deflate(let bufferSize, let level):
            #if canImport(Zlib)
            return Deflate(bufferSize: bufferSize, level: level).compress(span, configuration: .default)
            #else
            return nil
            #endif

        case .lz77(let searchBufferSize, let lookaheadBufferSize, let offsetBitWidth):
            #if canImport(CompressionLZ)
            switch offsetBitWidth {
            case 8:
                return LZ77<UInt8>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 16:
                return LZ77<UInt16>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 32:
                return LZ77<UInt32>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 64:
                return LZ77<UInt64>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
            case 128:
                if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
                    return LZ77<UInt128>(searchBufferSize: searchBufferSize, lookaheadBufferSize: lookaheadBufferSize).compress(span, configuration: .default)
                }
                return nil
            default:
                return nil
            }
            #else
            return nil
            #endif

        case .gzip(let bufferSize, let level, let memLevel, let strategy):
            #if canImport(Zlib)
            return Gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
                .compress(span, configuration: .default)
            #else
            return nil
            #endif

        default:
            return nil
        }
    }
}

#endif