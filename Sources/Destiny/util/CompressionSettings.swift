
#if Compression

import SwiftCompressionUtilities

public struct CompressionSettings: Sendable {
    package var flags:Flags.RawValue
    public package(set) var supportedCompressionAlgorithms:[CompressionAlgorithm:CompressorSettings]

    public init(
        enabled: Bool = true,
        compressOnlyIfResultIsSmaller: Bool = true,
        supportedCompressionAlgorithms: [CompressionAlgorithm:CompressorSettings] = [
            .brotli(
                quality: 11, // BROTLI_DEFAULT_QUALITY
                windowSize: 22, // BROTLI_DEFAULT_WINDOW
                mode: 0 // BROTLI_MODE_GENERIC
            ): .init(contentTypePrefixWhitelist: "text/"),
            .deflate(
                bufferSize: 32768,
                level: -1 // Z_DEFAULT_COMPRESSION
            ): .init(contentTypePrefixWhitelist: "text/"),
            .gzip(
                bufferSize: 32768,
                level: -1, // Z_DEFAULT_COMPRESSION
                memLevel: 8,
                strategy: 0 // Z_DEFAULT_STRATEGY
            ): .init(contentTypePrefixWhitelist: "text/"),
            .snappy: .init(contentTypePrefixWhitelist: "text/")
        ]
    ) {
        flags = Flags.pack(
            enabled: enabled,
            compressOnlyIfResultIsSmaller: compressOnlyIfResultIsSmaller
        )
        self.supportedCompressionAlgorithms = supportedCompressionAlgorithms
    }

    public var isEnabled: Bool {
        isFlag(.enabled)
    }
    public var compressOnlyIfResultIsSmaller: Bool {
        isFlag(.compressOnlyIfResultIsSmaller)
    }

    func isFlag(_ flag: Flags) -> Bool {
        flags & flag.rawValue != 0
    }

    mutating func setFlag(_ flag: Flags, _ value: Bool) {
        if value {
            flags |= flag.rawValue
        } else {
            flags &= ~flag.rawValue
        }
    }
}

// MARK: Flags
extension CompressionSettings {
    package enum Flags: UInt8 {
        case enabled = 1
        case compressOnlyIfResultIsSmaller = 2
    }
}
extension CompressionSettings.Flags {
    package static func pack(
        enabled: Bool,
        compressOnlyIfResultIsSmaller: Bool
    ) -> RawValue {
        (enabled ? Self.enabled.rawValue : 0)
        | (compressOnlyIfResultIsSmaller ? Self.compressOnlyIfResultIsSmaller.rawValue : 0)
    }
}

#endif