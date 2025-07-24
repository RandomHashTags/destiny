
public protocol ResponseBodyProtocol: Sendable {
    @inlinable
    var count: Int { get }

    func responderDebugDescription(_ input: String) -> String
    func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String

    @inlinable
    func string() -> String

    @inlinable
    mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws

    @inlinable
    var hasDateHeader: Bool { get }

    @inlinable
    func customInitializer(bodyString: String) -> String?
}

extension ResponseBodyProtocol {
    @inlinable public func customInitializer(bodyString: String) -> String? { nil }
}

// MARK: Default conformances
extension String: ResponseBodyProtocol {
    public var debugDescription: String {
        "\"\(self)\""
    }

    public func responderDebugDescription(_ input: String) -> String {
        input.debugDescription
    }

    public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }

    @inlinable
    public var count: Int {
        utf8.count
    }
    
    @inlinable
    public func string() -> String {
        self
    }

    @inlinable public var hasDateHeader: Bool { false }

    @inlinable
    public mutating func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        self.withUTF8 { p in
            buffer.copyBuffer(p, at: &index)
        }
    }
}

extension StaticString: ResponseBodyProtocol {
    public var debugDescription: String {
        "\"\(self.description)\")"
    }

    public func responderDebugDescription(_ input: String) -> String {
        fatalError("cannot do that") // TODO: fix?
    }

    public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String {
        try responderDebugDescription(input.string(escapeLineBreak: true))
    }

    @inlinable
    public var count: Int {
        utf8CodeUnitCount
    }
    
    @inlinable
    public func string() -> String {
        description
    }

    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        self.withUTF8Buffer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }

    @inlinable public var hasDateHeader: Bool { false }
}

#if canImport(FoundationEssentials) || canImport(Foundation)

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension Data: ResponseBodyProtocol {
    public var debugDescription: String {
        "Data(\(self))"
    }

    public func responderDebugDescription(_ input: String) -> String {
        Self(Data(input.utf8)).debugDescription
    }

    public func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String{
        try responderDebugDescription(input.string(escapeLineBreak: false))
    }
    
    @inlinable
    public func string() -> String {
        .init(decoding: self, as: UTF8.self)
    }

    @inlinable
    public func write(to buffer: UnsafeMutableBufferPointer<UInt8>, at index: inout Int) throws {
        self.span.withUnsafeBufferPointer { p in
            buffer.copyBuffer(p, at: &index)
        }
    }

    @inlinable public var hasDateHeader: Bool { false }
}

#endif