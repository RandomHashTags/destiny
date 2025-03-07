//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyUtilities

public struct DynamicResponse : DynamicResponseProtocol {
    public typealias ConcreteHTTPMessage = HTTPMessage

    public var timestamps:DynamicRequestTimestamps
    public var message:HTTPMessage
    public var parameters:[String]

    public init(
        timestamps: DynamicRequestTimestamps = DynamicRequestTimestamps(received: .now, loaded: .now, processed: .now),
        message: HTTPMessage,
        parameters: [String]
    ) {
        self.timestamps = timestamps
        self.message = message
        self.parameters = parameters
    }

    public var debugDescription : String {
        return "DynamicResponse(message: \(message.debugDescription), parameters: \(parameters))"
    }
}