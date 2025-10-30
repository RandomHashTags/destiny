
extension HTTPRequestMethod: HTTPRequestMethodProtocol {
    public init(_ method: some HTTPRequestMethodProtocol) {
        self.init(name: method.rawNameString())
    }
}