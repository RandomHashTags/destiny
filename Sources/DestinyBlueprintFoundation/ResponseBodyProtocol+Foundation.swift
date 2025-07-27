
import DestinyBlueprint

#if canImport(FoundationEssentials)
import struct FoundationEssentials.Data
#else
import struct Foundation.Data
#endif

extension Data: ResponseBodyProtocol {
    @inlinable
    public func string() -> String {
        .init(decoding: self, as: UTF8.self)
    }

    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        self.span.withUnsafeBufferPointer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}