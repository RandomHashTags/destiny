
/// Core protocol that writes its response to requests.
public protocol RouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a file descriptor.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    #if Inlinable
    @inlinable
    #endif
    func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: RouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: socket)
        } catch {
            throw .socketError(error)
        }
        completionHandler()
    }
}
#endif

extension StaticString: RouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: socket)
        } catch {
            throw .socketError(error)
        }
        completionHandler()
    }
}

extension [UInt8]: RouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: some HTTPRouterProtocol,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: socket)
        } catch {
            throw .socketError(error)
        }
        completionHandler()
    }
}