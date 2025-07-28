
import DestinyDefaults
import Foundation

// MARK: Accept datetime
extension HTTPRequestHeaders {
    public var acceptDatetime: Date? {
        guard let s = acceptDatetimeString else { return nil }
        return DateFormatter().date(from: s)
    }
}

// MARK: Date
extension HTTPRequestHeaders {
    @discardableResult
    @inlinable
    public mutating func date(_ date: Date?) -> Self {
        guard let date else { return self }
        self.dateString = DateFormatter().string(from: date)
        return self
    }
}