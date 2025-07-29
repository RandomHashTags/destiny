
extension HTTPMediaTypes {
    static var messageMediaTypes: [HTTPMediaType] {
        [
            .init("bhttp", ""),
            .init("cpim", "CPIM"),
            .init("deliveryStatus", "delivery-status"),
            .init("dispositionNotification", "disposition-notification"),
            .init("example", ""),
            .init("externalBody", "external-body"),
            .init("feedbackReport", "feedback-report"),
            .init("global", ""),
            .init("globalDeliveryStatus", "global-delivery-status"),
            .init("globalDispositionNotification", "global-disposition-notification"),
            .init("globalHeaders", "global-headers"),
            .init("http", ""),
            .init("imdnXML", "imdn+xml"),
            .init("mls", ""),
            .init("ohttpReq", "ohttp-req"),
            .init("ohttpRes", "ohttp-res"),
            .init("partial", ""),
            .init("rfc822", ""),
            .init("sip", ""),
            .init("sipfrag", ""),
            .init("trackingStatus", "tracking-status"),
            .init("wsc", "vnd.wfa.wsc")
        ]
    }
}