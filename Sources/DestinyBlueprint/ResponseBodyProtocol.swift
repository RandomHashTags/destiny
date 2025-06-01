
public protocol ResponseBodyProtocol: CustomDebugStringConvertible, Sendable {
    @inlinable
    var count: Int { get }

    var responderDebugDescription: String { get }
    func responderDebugDescription(_ input: String) -> String
    func responderDebugDescription<T: HTTPMessageProtocol>(_ input: T) throws -> String

    @inlinable
    func string() -> String

    @inlinable
    func bytes() -> [UInt8]

    @inlinable
    func bytes(_ closure: (inout InlineVLArray<UInt8>) throws -> Void) rethrows

    @inlinable
    var hasDateHeader: Bool { get }

    @inlinable
    var hasCustomInitializer: Bool { get }

    @inlinable
    func customInitializer(bodyString: String) -> String
}

extension ResponseBodyProtocol {
    @inlinable public var hasCustomInitializer: Bool { false }
    @inlinable public func customInitializer(bodyString: String) -> String { "" }
}