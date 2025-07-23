
public protocol HTTPRequestMethodProtocol: Equatable, Sendable {

    var rawName: any InlineArrayProtocol { get }

    @inlinable
    func rawNameString() -> String
}