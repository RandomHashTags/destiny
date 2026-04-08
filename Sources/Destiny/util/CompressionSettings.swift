
#if Compression

import SwiftCompression
import ZlibShim

public struct CompressionSettings: Sendable {
    var flags:Flags.RawValue
    public let supportedCompressionAlgorithms:[CompressionAlgorithm:CompressorSettings]

    public init(
        enabled: Bool = true,
        compressOnlyIfResultIsSmaller: Bool = true,
        supportedCompressionAlgorithms: [CompressionAlgorithm:CompressorSettings] = [
            .gzip(bufferSize: 1024, level: Z_DEFAULT_COMPRESSION, memLevel: 8, strategy: Z_DEFAULT_STRATEGY): .init(contentTypePrefixWhitelist: "text/")
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
    enum Flags: UInt8 {
        case enabled = 1
        case compressOnlyIfResultIsSmaller = 2
    }
}
extension CompressionSettings.Flags {
    static func pack(
        enabled: Bool,
        compressOnlyIfResultIsSmaller: Bool
    ) -> RawValue {
        (enabled ? Self.enabled.rawValue : 0)
        | (compressOnlyIfResultIsSmaller ? Self.compressOnlyIfResultIsSmaller.rawValue : 0)
    }
}

#endif