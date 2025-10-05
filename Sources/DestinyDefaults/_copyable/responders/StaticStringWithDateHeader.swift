
#if CopyableStaticStringWithDateHeader

import CustomOperators
import DestinyEmbedded

extension ResponseBody {
    #if Inlinable
    @inlinable
    #endif
    public static func staticStringWithDateHeader(_ value: StaticString) -> StaticStringWithDateHeader {
        .init(preDateValue: "", postDateValue: value)
    }

    #if Inlinable
    @inlinable
    #endif
    public static func staticStringWithDateHeader(preDateValue: StaticString, postDateValue: StaticString) -> StaticStringWithDateHeader {
        .init(preDateValue: preDateValue, postDateValue: postDateValue)
    }
}

public struct StaticStringWithDateHeader: Sendable {
    public let preDateValue:StaticString
    public let postDateValue:StaticString

    @usableFromInline
    let payload:DateHeaderPayload

    public init(_ value: StaticString) {
        self.preDateValue = ""
        self.postDateValue = value
        payload = .init(
            preDate: preDateValue,
            postDate: value
        )
    }

    public init(
        preDateValue: StaticString,
        postDateValue: StaticString
    ) {
        self.preDateValue = preDateValue
        self.postDateValue = postDateValue
        payload = .init(
            preDate: preDateValue,
            postDate: postDateValue
        )
    }

    #if Inlinable
    @inlinable
    #endif
    public var count: Int {
        preDateValue.utf8CodeUnitCount +! HTTPDateFormat.InlineArrayResult.count +! postDateValue.utf8CodeUnitCount
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
extension StaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) {
        index = 0
        buffer.copyBuffer(baseAddress: preDateValue.utf8Start, count: preDateValue.utf8CodeUnitCount, at: &index)
        HTTPDateFormat.nowInlineArray.span.withUnsafeBufferPointer {
            buffer.copyBuffer($0, at: &index)
        }
        buffer.copyBuffer(baseAddress: postDateValue.utf8Start, count: postDateValue.utf8CodeUnitCount, at: &index)
    }
}

// MARK: Respond
extension StaticStringWithDateHeader {
    #if Inlinable
    @inlinable
    #endif
    #if InlineAlways
    @inline(__always)
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        try payload.write(to: socket)
        completionHandler()
    }
}

#if canImport(DestinyBlueprint)

import DestinyBlueprint

// MARK: Conformances
extension StaticStringWithDateHeader: ResponseBodyProtocol {}
extension StaticStringWithDateHeader: StaticRouteResponderProtocol {}

#endif

#endif