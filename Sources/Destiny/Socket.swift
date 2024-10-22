//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import DestinyUtilities


// MARK: Socket
public struct Socket : SocketProtocol, ~Copyable {
    @inlinable
    static func noSigPipe(fileDescriptor: Int32) {
        #if os(Linux)
        #else
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
        #endif
    }
    public static let bufferLength:Int = 1024
    public let fileDescriptor:Int32
    public var closed:Bool

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        closed = false
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    deinit { deinitalize() }
}

public extension SocketProtocol where Self : ~Copyable {
    @inlinable
    func readLineStackString<T: SIMD>() throws -> T where T.Scalar: BinaryInteger { // read just the method, path & http version
        var string:T = T()
        var i:Int = 0, index:T.Scalar = 0
        while index != 10 && i != T.scalarCount {
            index = T.Scalar(try self.readByte())
            if index > 13 {
                string[i] = index
                i += 1
            }
        }
        return string
    }
}