
#if Compression

import SwiftCompression

extension CompressionAlgorithm {
    func compress(span: Span<UInt8>) -> [UInt8]? {
        switch self {
        case .brotli(let quality, let windowSize, let mode):
            return Brotli(quality: quality, windowSize: windowSize, mode: mode)
                .compress(span: span, configuration: .default)
        case .gzip(let bufferSize, let level, let memLevel, let strategy):
            return Gzip(bufferSize: bufferSize, level: level, memLevel: memLevel, strategy: strategy)
                .compress(span: span, configuration: .default)
        default:
            return nil
        }
    }
}

#endif