
public protocol HTTPRequestMethodProtocol: Hashable, Sendable {
    var rawName: InlineArray<20, UInt8> { get }
}