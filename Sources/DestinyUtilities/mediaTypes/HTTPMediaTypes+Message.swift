//
//  HTTPMediaTypes+Message.swift
//
//
//  Created by Evan Anderson on 12/30/24.
//

extension HTTPMediaTypes {
    #HTTPFieldContentType(
        category: "message",
        values: [
            "bhttp" : .init(""),
            "cpim" : .init("CPIM"),
            "deliveryStatus" : .init("delivery-status"),
            "dispositionNotification" : .init("disposition-notification"),
            "example" : .init(""),
            "externalBody" : .init("external-body"),
            "feedbackReport" : .init("feedback-report"),
            "global" : .init(""),
            "globalDeliveryStatus" : .init("global-delivery-status"),
            "globalDispositionNotification" : .init("global-disposition-notification"),
            "globalHeaders" : .init("global-headers"),
            "http" : .init(""),
            "imdnXML" : .init("imdn+xml"),
            "mls" : .init(""),
            "ohttpReq" : .init("ohttp-req"),
            "ohttpRes" : .init("ohttp-res"),
            "partial" : .init(""),
            "rfc822" : .init(""),
            "sip" : .init(""),
            "sipfrag" : .init(""),
            "trackingStatus" : .init("tracking-status"),
            "wsc" : .init("vnd.wfa.wsc")
        ]
    )
}