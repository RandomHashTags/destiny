import DestinyBlueprint

public enum HTTPMediaTypeMessage: String, HTTPMediaTypeProtocol {
    case bhttp
    case cpim
    case deliveryStatus
    case dispositionNotification
    case example
    case externalBody
    case feedbackReport
    case global
    case globalDeliveryStatus
    case globalDispositionNotification
    case globalHeaders
    case http
    case imdnXML
    case mls
    case ohttpReq
    case ohttpRes
    case partial
    case rfc822
    case sip
    case sipfrag
    case trackingStatus
    case wsc

    @inlinable
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {

        default: return nil
        }
    }

    @inlinable
    public var type: String {
        "message"
    }

    @inlinable
    public var subType: String {
        switch self {
        case .bhttp: rawValue
        case .cpim: "CPIM"
        case .deliveryStatus: "delivery-status"
        case .dispositionNotification: "disposition-notification"
        case .example: rawValue
        case .externalBody: "external-body"
        case .feedbackReport: "feedback-report"
        case .global: rawValue
        case .globalDeliveryStatus: "global-delivery-status"
        case .globalDispositionNotification: "global-disposition-notification"
        case .globalHeaders: "global-headers"
        case .http: rawValue
        case .imdnXML: "imdn+xml"
        case .mls: rawValue
        case .ohttpReq: "ohttp-req"
        case .ohttpRes: "ohttp-res"
        case .partial: rawValue
        case .rfc822: rawValue
        case .sip: rawValue
        case .sipfrag: rawValue
        case .trackingStatus: "tracking-status"
        case .wsc: "vnd.wfa.wsc"
        }
    }
}