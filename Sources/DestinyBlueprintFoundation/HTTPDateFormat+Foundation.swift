
import DestinyBlueprint

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension HTTPDateFormat {
    @inlinable
    public static func get(date: Date) -> InlineArrayResult {
        let components = Calendar.current.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: date)
        let values = (
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0,
            components.weekday ?? 0,
            components.hour ?? 0,
            components.minute ?? 0,
            components.second ?? 0
        )
        return get(
            year: values.0,
            month: UInt8(values.1) - 1,
            day: UInt8(values.2),
            dayOfWeek: UInt8(values.3) - 1,
            hour: UInt8(values.4),
            minute: UInt8(values.5),
            second: UInt8(values.6)
        )
    }
}