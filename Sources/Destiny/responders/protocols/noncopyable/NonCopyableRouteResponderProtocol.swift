
#if NonCopyable

/// Core protocol that writes its response to requests.
public protocol NonCopyableRouteResponderProtocol: Sendable, ~Copyable {
    /// Writes a response to a socket.
    /// 
    /// - Parameters:
    ///   - router: Router this responder is stored in.
    ///   - request: Socket's request.
    /// 
    /// - Throws: `ResponderError`
    func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(ResponderError)
}

// MARK: Default conformances

#if StringRouteResponder
extension String: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
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

extension StaticString: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
        request: inout HTTPRequest
    ) throws(ResponderError) {
        do throws(SocketError) {
            try self.write(to: request.fileDescriptor)
        } catch {
            throw .socketError(error)
        }
    }
}

extension [UInt8]: NonCopyableRouteResponderProtocol {
    public func respond(
        provider: some SocketProvider,
        router: borrowing some NonCopyableHTTPRouterProtocol & ~Copyable,
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