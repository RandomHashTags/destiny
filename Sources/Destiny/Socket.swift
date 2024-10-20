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
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
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