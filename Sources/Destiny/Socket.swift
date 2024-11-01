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