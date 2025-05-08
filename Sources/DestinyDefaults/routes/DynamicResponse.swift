//
//  DynamicResponse.swift
//
//
//  Created by Evan Anderson on 10/31/24.
//

import DestinyBlueprint
import DestinyUtilities

public struct DynamicResponse: DynamicResponseProtocol {
    public var timestamps:DynamicRequestTimestamps
    public var message:any HTTPMessageProtocol
    public var parameters:[String]

    public init(
        timestamps: DynamicRequestTimestamps = DynamicRequestTimestamps(received: .now, loaded: .now, processed: .now),
        message: any HTTPMessageProtocol,
        parameters: [String]
    ) {
        self.timestamps = timestamps
        self.message = message
        self.parameters = parameters
    }

    public var debugDescription: String {
        "DynamicResponse(message: \(message.debugDescription), parameters: \(parameters))"
    }

    @inlinable
    public func parameter(at index: Int) -> String {
        parameters[index]
    }

    @inlinable
    public mutating func setParameter(at index: Int, value: InlineVLArray<UInt8>) {
        parameters[index] = value.string()
    }
}