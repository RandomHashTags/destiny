
public protocol ResponseBodyProtocol: CustomDebugStringConvertible, Sendable {
    static var id: UInt8 { get }
    var id: UInt8 { get }

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
}

extension ResponseBodyProtocol {
    @inlinable public var id: UInt8 { Self.id }
}