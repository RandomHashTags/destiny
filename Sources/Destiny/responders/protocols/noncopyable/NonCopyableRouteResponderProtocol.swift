
#if NonCopyable


/// Core protocol that writes its response to requests.
public protocol NonCopyableRouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - socket: Socket to write to.
    ///   - request: Socket's request.
    ///   - completionHandler: Closure that should be called when the socket should be released.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
        completionHandler: @Sendable @escaping () -> Void
    ) throws(ResponderError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: NonCopyableRouteResponderProtocol {
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
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

extension StaticString: NonCopyableRouteResponderProtocol {
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
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
    public func respond(
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        socket: some FileDescriptor,
        request: inout HTTPRequest,
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