
import DestinyDefaultsNonEmbedded

// MARK: CustomDebugStringConvertible
extension DynamicRouteResponder: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        DynamicRouteResponder(
            path: \(path),
            defaultResponse: \(_defaultResponse),
            logic: \(logicDebugDescription)
        )
        """
    }
}