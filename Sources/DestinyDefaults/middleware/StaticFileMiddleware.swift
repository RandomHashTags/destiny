/*
import DestinyBlueprint

// MARK: StaticFileMiddleware
public struct StaticFileMiddleware: Sendable { // TODO: finish

    let filePath:String
    let endpoint:String

    public init(filePath: String, endpoint: String) {
        self.filePath = filePath
        self.endpoint = endpoint
    }

    public func load() {
    }

    /// - Returns: All the routes associated with the files for the given path.
    public func routes(
        version: HTTPVersion,
        method: some HTTPRequestMethodProtocol = HTTPStandardRequestMethod.get,
        charset: Charset? = .utf8
    ) throws(MiddlewareError) -> [StaticRoute] {
        return []
    }
}

// MARK: Conformances
extension StaticFileMiddleware: FileMiddlewareProtocol {}
*/