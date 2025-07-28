
import DestinyBlueprint
import DestinyDefaults
import Foundation

// MARK: Retry after date
extension HTTPResponseHeaders {
    public var retryAfterDate: Date? {
        guard let s = retryAfterDateString else { return nil }
        return DateFormatter().date(from: s)
    }

    @discardableResult
    @inlinable
    public mutating func retryAfter(_ date: Date?) -> Self {
        guard let date else {
            retryAfterDateString = nil
            return self
        }
        retryAfterDateString = DateFormatter().string(from: date)
        return self
    }
}