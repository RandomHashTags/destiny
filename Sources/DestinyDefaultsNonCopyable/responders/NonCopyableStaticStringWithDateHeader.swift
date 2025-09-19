
import DestinyBlueprint
import DestinyDefaults

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStaticStringWithDateHeader(_ value: StaticString) -> NonCopyableStaticStringWithDateHeader {
        .init(preDateValue: "", postDateValue: value)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func nonCopyableStaticStringWithDateHeader(preDateValue: StaticString, postDateValue: StaticString) -> NonCopyableStaticStringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue)
    }
}

public struct NonCopyableStaticStringWithDateHeader: ResponseBodyProtocol, ~Copyable {
    public let preDateValue:StaticString
    public let postDateValue:StaticString

    @usableFromInline
    let payload:Payload

    public init(_ value: StaticString) {
        self.preDateValue = ""
        self.postDateValue = value
        payload = .init(
            preDatePointer: preDateValue.utf8Start,
            preDatePointerCount: preDateValue.utf8CodeUnitCount,
            postDatePointer: postDateValue.utf8Start,
            postDatePointerCount: postDateValue.utf8CodeUnitCount
        )
    }

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        payload = .init(
            preDatePointer: preDateValue.utf8Start,
            preDatePointerCount: preDateValue.utf8CodeUnitCount,
            postDatePointer: postDateValue.utf8Start,
            postDatePointerCount: postDateValue.utf8CodeUnitCount
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.utf8CodeUnitCount + HTTPDateFormat.InlineArrayResult.count + postDateValue.utf8CodeUnitCount
    }
    
    #if Inlinable
    @inlinable
    #endif
    public func string() -> String {
        "\(preDateValue)\(HTTPDateFormat.placeholder)\(postDateValue)"
    }

    #if Inlinable
    @inlinable
    #endif
    public var hasDateHeader: Bool {
        true
    }
}

// MARK: Write to buffer
extension NonCopyableStaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        preDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
        HTTPDateFormat.nowInlineArray.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
        postDateValue.withUTF8Buffer {
            buffer.copyBuffer($0, at: &index)
        }
    }
}

// MARK: Respond
extension NonCopyableStaticStringWithDateHeader: NonCopyableStaticRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(socket: socket)
        completionHandler()
    }
}

// MARK: Payload
extension NonCopyableStaticStringWithDateHeader {
    @usableFromInline
    struct Payload: @unchecked Sendable, ~Copyable {
        @usableFromInline let preDatePointer:UnsafePointer<UInt8>
        @usableFromInline let preDatePointerCount:Int
        @usableFromInline let postDatePointer:UnsafePointer<UInt8>
        @usableFromInline let postDatePointerCount:Int

        #if Inlinable
        @inlinable
        #endif
        #if InlineAlways
        @inline(__always)
        #endif
        func write(socket: some FileDescriptor) throws(ResponderError) {
            var err:SocketError? = nil
            HTTPDateFormat.nowInlineArray.withUnsafeBufferPointer { datePointer in
                do throws(SocketError) {
                    try socket.writeBuffers([
                        (preDatePointer, preDatePointerCount),
                        (datePointer.baseAddress!, HTTPDateFormat.InlineArrayResult.count),
                        (postDatePointer, postDatePointerCount)
                    ])
                } catch {
                    err = error
                }
            }
            if let err {
                throw .socketError(err)
            }
        }
    }
}