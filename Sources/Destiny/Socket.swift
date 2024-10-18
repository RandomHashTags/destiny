//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import DestinyUtilities


// MARK: Socket
struct Socket : SocketProtocol, ~Copyable {
    static func noSigPipe(fileDescriptor: Int32) {
        var no_sig_pipe:Int32 = 0
        setsockopt(fileDescriptor, SOL_SOCKET, SO_NOSIGPIPE, &no_sig_pipe, socklen_t(MemoryLayout<Int32>.size))
    }
    static let bufferLength:Int = 1024
    let fileDescriptor:Int32
    var closed:Bool

    init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        closed = false
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }

    deinit { deinitalize() }
}