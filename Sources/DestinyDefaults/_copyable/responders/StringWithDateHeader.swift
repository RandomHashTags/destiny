
#if CopyableStringWithDateHeader

import DestinyEmbedded
import UnwrapArithmeticOperators

public struct StringWithDateHeader: Sendable {
    public let preDateValue:String.UTF8View
    public let postDateValue:String.UTF8View
    public let value:String.UTF8View

    public init(_ value: String) {
        preDateValue = "".utf8
        postDateValue = "".utf8
        self.value = value.utf8
    }
    public init(
        preDateValue: String,
        postDateValue: String,
        value: String
    ) {
        self.preDateValue = preDateValue.utf8
        self.postDateValue = postDateValue.utf8
        self.value = value.utf8
    }

    public var count: Int {
        preDateValue.count +! HTTPDateFormat.InlineArrayResult.count +! postDateValue.count +! value.count
    }
    
    public func string() -> String {
        String(preDateValue) + HTTPDateFormat.placeholder + String(postDateValue) + String(value)
    }

    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension StringWithDateHeader {
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
        buffer.copyBuffer(baseAddress: HTTPDateFormat.nowUnsafeBufferPointer.baseAddress!, count: HTTPDateFormat.count, at: &index)
        postDateValue.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
        value.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Respond
extension StringWithDateHeader {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    public func respond(
        socket: some FileDescriptor,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        preDateValue.withContiguousStorageIfAvailable { preDatePointer in
            postDateValue.withContiguousStorageIfAvailable { postDatePointer in
                value.withContiguousStorageIfAvailable { valuePointer in
                    do throws(SocketError) {
                        try socket.writeBuffers4(
                            preDatePointer,
                            HTTPDateFormat.nowUnsafeBufferPointer, // TODO: fix? (see `HTTPDateFormat.nowUnsafeBufferPointer` warning)
                            postDatePointer,
                            valuePointer
                        )
                    } catch {
                        err = error
                    }
                }
            }
        }
        if let err {
            throw .socketError(err)
        }
        completionHandler()
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension StringWithDateHeader: ResponseBodyProtocol {}

extension StringWithDateHeader: RouteResponderProtocol {
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

extension StringWithDateHeader: NonCopyableRouteResponderProtocol {
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif