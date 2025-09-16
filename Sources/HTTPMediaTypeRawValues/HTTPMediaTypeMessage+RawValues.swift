
import DestinyDefaults

extension HTTPMediaTypeMessage: RawRepresentable {
    public typealias RawValue = String

    #if Inlinable
    @inlinable
    #endif
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "bhttp": self = .bhttp
        case "cpim": self = .cpim
        case "deliveryStatus": self = .deliveryStatus
        case "dispositionNotification": self = .dispositionNotification
        case "example": self = .example
        case "externalBody": self = .externalBody
        case "feedbackReport": self = .feedbackReport
        case "global": self = .global
        case "globalDeliveryStatus": self = .globalDeliveryStatus
        case "globalDispositionNotification": self = .globalDispositionNotification
        case "globalHeaders": self = .globalHeaders
        case "http": self = .http
        case "imdnXML": self = .imdnXML
        case "mls": self = .mls
        case "ohttpReq": self = .ohttpReq
        case "ohttpRes": self = .ohttpRes
        case "partial": self = .partial
        case "rfc822": self = .rfc822
        case "sip": self = .sip
        case "sipfrag": self = .sipfrag
        case "trackingStatus": self = .trackingStatus
        case "wsc": self = .wsc
        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var rawValue: String {
        switch self {
        case .bhttp: "bhttp"
        case .cpim: "cpim"
        case .deliveryStatus: "deliveryStatus"
        case .dispositionNotification: "dispositionNotification"
        case .example: "example"
        case .externalBody: "externalBody"
        case .feedbackReport: "feedbackReport"
        case .global: "global"
        case .globalDeliveryStatus: "globalDeliveryStatus"
        case .globalDispositionNotification: "globalDispositionNotification"
        case .globalHeaders: "globalHeaders"
        case .http: "http"
        case .imdnXML: "imdnXML"
        case .mls: "mls"
        case .ohttpReq: "ohttpReq"
        case .ohttpRes: "ohttpRes"
        case .partial: "partial"
        case .rfc822: "rfc822"
        case .sip: "sip"
        case .sipfrag: "sipfrag"
        case .trackingStatus: "trackingStatus"
        case .wsc: "wsc"
        }
    }
}