
public protocol HTTPRequestMethodProtocol: Sendable, ~Copyable {
    func rawNameString() -> String
}