//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation

// MARK: Socket
public struct Socket: SocketProtocol, ~Copyable {
    @inlinable
    static func noSigPipe(fileDescriptor: Int32) {
        #if os(Linux)
        #else
            var no_sig_pipe: Int32 = 0
            setsockopt(
                fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe,
                socklen_t(MemoryLayout<Int32>.size))
        #endif
    }
    public static let bufferLength: Int = 1024
    public let fileDescriptor: Int32
    public var closed: Bool

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        closed = false
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    deinit { deinitalize() }
}

extension SocketProtocol where Self: ~Copyable {
    @inlinable
    public func readLineStackString<T: SIMD>() throws -> T where T.Scalar: BinaryInteger {  // read just the method, path & http version
        var string: T = T()
        var i: Int = 0
        var index: T.Scalar = 0
        while true {
            index = try T.Scalar(readByte())
            if index == 10 || i == T.scalarCount {
                break
            } else if index == 13 {
                continue
            }
            string[i] = index
            i += 1
        }
        return string
    }
}
