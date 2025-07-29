
public protocol HTTPRequestMethodProtocol: Equatable, Sendable {

    var rawName: any InlineArrayProtocol { get }

    func rawNameString() -> String
}