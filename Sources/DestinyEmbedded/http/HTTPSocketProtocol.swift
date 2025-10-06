
import UnwrapArithmeticOperators

/// Core protocol that handles incoming http requests.
public protocol HTTPSocketProtocol: SocketProtocol, ~Copyable {
}

extension HTTPSocketProtocol where Self: ~Copyable {
    /// Writes 2 bytes (carriage return and line feed) to the socket.
    #if Inlinable
    @inlinable
    #endif
    public func writeCRLF(
        count: Int = 1
    ) throws(SocketError) {
        let capacity = count * 2
        var err:SocketError? = nil
        withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity, { p in
            var i = 0
            while i < count {
                p[i] = .carriageReturn
                i +=! 1
                p[i] = .lineFeed
                i +=! 1
            }
            do throws(SocketError) {
                try writeBuffer(p.baseAddress!, length: capacity)
            } catch {
                err = error
            }
        })
        if let err {
            throw err
        }
    }
}