//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities
import Foundation
import HTTPTypes
import Logging

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

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }
}

public extension SocketProtocol where Self : ~Copyable {
    @inlinable
    func readLineStackString<T: SIMD>() throws -> T where T.Scalar: BinaryInteger { // read just the method, path & http version
        var string:T = T()
        var i:Int = 0, char:UInt8 = 0
        while true {
            char = try readByte()
            if char == 10 || i == T.scalarCount {
                break
            } else if char == 13 {
                continue
            }
            string[i] = T.Scalar(char)
            i += 1
        }
        return string
    }
}