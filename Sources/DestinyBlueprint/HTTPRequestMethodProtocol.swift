
public protocol HTTPRequestMethodProtocol: CustomDebugStringConvertible, Equatable, Sendable {

    var rawName: any InlineArrayProtocol { get }

    @inlinable
    func rawNameString() -> String
}