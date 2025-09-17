
import DestinyDefaults

extension ConditionalRouteResponder: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        ConditionalRouteResponder(
            staticConditions: \(staticConditionsDescription),
            staticResponders: \(staticRespondersDescription),
            dynamicConditions: \(dynamicConditionsDescription),
            dynamicResponders: \(dynamicRespondersDescription)
        )
        """
    }
}