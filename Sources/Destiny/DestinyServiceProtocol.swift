

/// Any service.
public protocol DestinyServiceProtocol: Sendable, ~Copyable {
    /// Throws: `ServiceError`
    func run() async throws(ServiceError)

    /// Shuts down the service.
    /// 
    /// - Throws: `ServiceError`
    func shutdown() async throws(ServiceError)
}