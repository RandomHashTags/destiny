
// memcpy
#if canImport(Android)
import Android
#elseif canImport(Bionic)
import Bionic
#elseif canImport(Darwin)
import Darwin
#elseif canImport(SwiftGlibc)
import Glibc
#elseif canImport(Musl)
import Musl
#elseif canImport(WASILibc)
import WASILibc
#elseif canImport(Windows)
import Windows
#elseif canImport(WinSDK)
import WinSDK
#endif

import DestinyBlueprint
import VariableLengthArray

/// Default HTTP Start Line implementation.
public struct HTTPStartLine: HTTPStartLineProtocol, ~Copyable {
    public let method:VLArray<UInt8>
    public let path:VLArray<UInt8>
    public let version:HTTPVersion
    public let endIndex:Int

    @inlinable
    public init(
        method: consuming VLArray<UInt8>,
        path: consuming VLArray<UInt8>,
        version: HTTPVersion,
        endIndex: Int
    ) {
        self.method = method
        self.path = path
        self.version = version
        self.endIndex = endIndex
    }
}

// MARK: Load
extension HTTPStartLine {
    @inlinable
    public static func load(
        buffer: some InlineByteArrayProtocol,
        _ body: (consuming Self) throws(SocketError) -> Void
    ) throws(SocketError) {
        var offset = 0
        var methodEndIndex = 0
        while offset < buffer.count, methodEndIndex == 0 {
            if buffer.itemAt(index: offset) == .space {
                methodEndIndex = offset
                break
            }
            offset += 1
        }
        guard methodEndIndex != 0 else {
            throw .malformedRequest()
        }
        offset += 1

        var err:SocketError? = nil
        buffer.withUnsafeBufferPointer { bufferPointer in
            var targetPathEndIndex = 0
            for i in offset..<buffer.count {
                if bufferPointer[i] == .space {
                    targetPathEndIndex = i
                    break
                }
            }
            do throws(SocketError) {
                guard targetPathEndIndex != 0 else {
                    throw .malformedRequest()
                }
            } catch {
                err = error
            }
            if err == nil {
                withUnsafeTemporaryAllocation(of: UInt8.self, capacity: methodEndIndex, { methodBuffer in
                    for i in 0..<methodEndIndex {
                        methodBuffer[i] = buffer.itemAt(index: i)
                    }
                    offset = methodEndIndex + 1
                    let pathCount = targetPathEndIndex - methodEndIndex - 1
                    withUnsafeTemporaryAllocation(of: UInt8.self, capacity: pathCount, { pathBuffer in
                        if pathCount <= 128 {
                            for i in 0..<pathCount {
                                pathBuffer[i] = bufferPointer[offset]
                                offset += 1
                            }
                            offset += 1
                        } else {
                            memcpy(pathBuffer.baseAddress!, bufferPointer.baseAddress! + offset, pathCount)
                            offset += pathCount + 1
                        }
                        let methodArray = VLArray<UInt8>(_storage: methodBuffer)
                        let pathArray = VLArray<UInt8>(_storage: pathBuffer)
                        var versionArray:InlineArray<8, UInt8> = .init(repeating: 0)
                        for i in 0..<8 {
                            versionArray[i] = bufferPointer[offset]
                            offset += 1
                        }
                        if let version = HTTPVersion(token: versionArray) {
                            let startLine = HTTPStartLine.init(
                                method: methodArray,
                                path: pathArray,
                                version: version,
                                endIndex: targetPathEndIndex + 9
                            )
                            do throws(SocketError) {
                                try body(startLine)
                                return
                            } catch {
                                err = error
                            }
                        } else {
                            err = .malformedRequest()
                        }
                    })
                })
            }
        }
        if let err {
            throw err
        }
    }
}