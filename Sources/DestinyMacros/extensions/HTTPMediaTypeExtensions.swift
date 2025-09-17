
import DestinyBlueprint

// MARK: CustomDebugStringConvertible
extension HTTPMediaType: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "HTTPMediaType(type: \"\(type)\", subType: \"\(subType)\")"
    }
}