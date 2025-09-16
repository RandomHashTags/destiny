
import DestinyBlueprint

public enum HTTPMediaTypeMessage: HTTPMediaTypeProtocol {
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

    #if Inlinable
    @inlinable
    #endif
    public init?(fileExtension: some StringProtocol) {
        switch fileExtension {

        default: return nil
        }
    }

    #if Inlinable
    @inlinable
    #endif
    public var type: String {
        "message"
    }

    #if Inlinable
    @inlinable
    #endif
    public var subType: String {
        switch self {
        case .bhttp: "bhttp"
        case .cpim: "CPIM"
        case .deliveryStatus: "delivery-status"
        case .dispositionNotification: "disposition-notification"
        case .example: "example"
        case .externalBody: "external-body"
        case .feedbackReport: "feedback-report"
        case .global: "global"
        case .globalDeliveryStatus: "global-delivery-status"
        case .globalDispositionNotification: "global-disposition-notification"
        case .globalHeaders: "global-headers"
        case .http: "http"
        case .imdnXML: "imdn+xml"
        case .mls: "mls"
        case .ohttpReq: "ohttp-req"
        case .ohttpRes: "ohttp-res"
        case .partial: "partial"
        case .rfc822: "rfc822"
        case .sip: "sip"
        case .sipfrag: "sipfrag"
        case .trackingStatus: "tracking-status"
        case .wsc: "vnd.wfa.wsc"
        }
    }
}