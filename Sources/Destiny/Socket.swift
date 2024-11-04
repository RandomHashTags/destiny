//
//  Socket.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import DestinyUtilities

// MARK: Socket
public struct Socket : SocketProtocol, ~Copyable {
    public static let bufferLength:Int = 1024
    public let fileDescriptor:Int32

    public init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
        Self.noSigPipe(fileDescriptor: fileDescriptor)
    }
}