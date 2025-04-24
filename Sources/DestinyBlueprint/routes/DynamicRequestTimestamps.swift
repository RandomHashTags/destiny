//
//  DynamicRequestTimestamps.swift
//
//
//  Created by Evan Anderson on 2/19/25.
//

public struct DynamicRequestTimestamps: Sendable {
    /// When the request was accepted.
    public var received:ContinuousClock.Instant

    /// When the request loaded its default values.
    public var loaded:ContinuousClock.Instant

    /// When the request was completely processed.
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