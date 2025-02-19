//
//  DynamicRequestTimestamps.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

public struct DynamicRequestTimestamps : Sendable {
    public var received:ContinuousClock.Instant
    public var loaded:ContinuousClock.Instant
    public var processed:ContinuousClock.Instant

    public init(
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        processed: ContinuousClock.Instant
    ) {
        self.received = received
        self.loaded = loaded
        self.processed = processed
    }
}