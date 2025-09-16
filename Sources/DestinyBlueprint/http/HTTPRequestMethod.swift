
/// Bare minimum storage to use an HTTP Request Method.
public struct HTTPRequestMethod: HTTPRequestMethodProtocol {
    @usableFromInline
    let name:String

    public init(name: String) {
        self.name = name
    }

    public init(_ method: some HTTPRequestMethodProtocol) {
        name = method.rawNameString()
    }

    #if Inlinable
    @inlinable
    #endif
    public func rawNameString() -> String {
        name
    }
}