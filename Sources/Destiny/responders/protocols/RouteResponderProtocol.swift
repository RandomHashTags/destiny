
/// Core protocol that writes its response to requests.
public protocol RouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - request: Socket's request.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(ResponderError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: request.fileDescriptor)
        } catch {
            throw .socketError(error)
        }
    }
}
#endif

extension StaticString: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: request.fileDescriptor)
        } catch {
            throw .socketError(error)
        }
    }
}

extension [UInt8]: RouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: some HTTPRouterProtocol,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: request.fileDescriptor)
        } catch {
            throw .socketError(error)
        }
    }
}