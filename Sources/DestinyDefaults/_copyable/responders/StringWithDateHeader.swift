
#if CopyableStringWithDateHeader

import CustomOperators
import DestinyEmbedded

extension ResponseBody {
    public static func stringWithDateHeader(_ value: String) -> StringWithDateHeader {
        .init(value)
    }

    public static func stringWithDateHeader(
        preDateValue: String,
        postDateValue: String,
        value: String
    ) -> StringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue, value: value)
    }
}

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

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.count +! HTTPDateFormat.InlineArrayResult.count +! postDateValue.count +! value.count
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        String(preDateValue) + HTTPDateFormat.placeholder + String(postDateValue) + String(value)
    }

    #if Inlinable
    @inlinable
    #endif
    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension StringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withContiguousStorageIfAvailable {
            buffer.copyBuffer($0, at: &index)
        }
        HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
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
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        socket: some FileDescriptor,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        var err:SocketError? = nil
        preDateValue.withContiguousStorageIfAvailable { preDatePointer in
            HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer { datePointer in
                postDateValue.withContiguousStorageIfAvailable { postDatePointer in
                    value.withContiguousStorageIfAvailable { valuePointer in
                        do throws(SocketError) {
                            try socket.writeBuffers([preDatePointer, datePointer, postDatePointer, valuePointer])
                        } catch {
                            err = error
                        }
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

extension StringWithDateHeader: StaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try respond(socket: socket, completionHandler: completionHandler)
    }
}

#endif

#endif