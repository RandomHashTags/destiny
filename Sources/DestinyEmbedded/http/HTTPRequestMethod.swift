
/// Bare minimum storage to use an HTTP Request Method.
public struct HTTPRequestMethod: Sendable {
    public let name:String

    public init(name: String) {
        self.name = name
    }

    #if Inlinable
    @inlinable
    #endif
    public func rawNameString() -> String {
        name
    }
}