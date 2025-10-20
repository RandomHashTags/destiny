
extension HTTPRequestMethod: HTTPRequestMethodProtocol {
    #if Inlinable
    @inlinable
    #endif
    public init(_ method: some HTTPRequestMethodProtocol) {
        self.init(name: method.rawNameString())
    }
}