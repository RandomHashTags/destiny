

/// Any service.
public protocol DestinyServiceProtocol: Sendable, ~Copyable {
    /// Throws: `DestinyError`
    func run() async throws(DestinyError)

    /// Shuts down the service.
    /// 
    /// - Throws: `DestinyError`
    func shutdown() async throws(DestinyError)
}