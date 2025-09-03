
/// Core Route Responder protocol that writes its responses to requests.
public protocol NonCopyableRouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: The router this responder is stored in.
    ///   - socket: The socket to write to.
    ///   - request: The socket's request.
    ///   - completionHandler: Call when you're done successfully responding.
    #if Inlinable
    @inlinable
    #endif
    func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout some HTTPRequestProtocol & ~Copyable,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)
}

// MARK: Default conformances
extension String: NonCopyableRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
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

extension StaticString: NonCopyableRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
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

extension [UInt8]: NonCopyableRouteResponderProtocol {
    #if Inlinable
    @inlinable
    #endif
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
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