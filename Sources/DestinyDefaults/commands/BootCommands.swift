
import ArgumentParser

/// Defines what boot options can be used for a server.
public struct BootCommands: ParsableCommand {
    @Option(
        name: .init([
            .customLong("hostname"),
            .customShort("h")
        ]),
        help: "Hostname the server uses."
    )
    public var hostname:String?
    
    @Option(
        name: .init([
            .customLong("port"),
            .customShort("p")
        ]),
        help: "Port to run the server on."
    )
    public var port:UInt16?

    @Option(
        name: .init([
            .customLong("backlog"),
            .customShort("b")
        ]),
        help: "Maximum amount of pending connections the server can have."
    )
    public var backlog:Int32?

    @Option(
        name: .init([
            .customLong("reuseaddress"),
            .customLong("ra", withSingleDash: true)
        ]),
        help: "Allows the server to reuse the address if its in a TIME_WAIT state, avoiding \"address already in use\" errors when restarting quickly."
    )
    public var reuseaddress:Bool = true

    @Option(
        name: .init([
            .customLong("reuseport"),
            .customLong("rp", withSingleDash: true)
        ]),
        help: "Allows multiple processes to bind to the same port, avoiding contention on a single socket, while enabling load balancing at the kernel level."
    )
    public var reuseport:Bool = true

    @Option(
        name: .init([
            .customLong("tcpnodelay"),
            .customLong("tcpnd", withSingleDash: true)
        ]),
        help: "Disables Nagle's algorithm, which buffers small packets before sending them, to improve latency for real-time applications."
    )
    public var tcpnodelay:Bool = true

    public init() {
    }
}