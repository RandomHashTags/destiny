//
//  Destiny.swift
//
//
//  Created by Evan Anderson on 10/17/24.
//

import Foundation
import DestinyUtilities
import HTTPTypes
import ServiceLifecycle
import Logging

@freestanding(expression)
public macro router(returnType: RouterReturnType, version: String, middleware: [Middleware], _ routes: Route...) -> Router = #externalMacro(module: "Macros", type: "Router")

// MARK: Application
public struct Application : Service {
    public let services:[Service]
    public let logger:Logger

    public init(
        services: [Service] = [],
        logger: Logger
    ) {
        self.services = services
        self.logger = logger
    }
    public func run() async throws {
        let service_group:ServiceGroup = ServiceGroup(configuration: .init(services: services, logger: logger))
        try await service_group.run()
    }
}

func strerror() -> String { String(cString: strerror(errno)) }


// MARK: StackString
public protocol StackStringProtocol : Hashable {
    associatedtype BufferType
    var buffer : BufferType { get set }
    var size : Int { get }
}
@attached(member, names: named(buffer), arbitrary)
public macro StackString(bufferLength: Int) = #externalMacro(module: "Macros", type: "StackString")

// MARK: StackString4
@StackString(bufferLength: 4)
public struct StackString4 : StackStringProtocol {
}

// MARK: StackString8
@StackString(bufferLength: 8)
public struct StackString8 : StackStringProtocol {
}

// MARK: StackString16
@StackString(bufferLength: 16)
public struct StackString16 : StackStringProtocol {
}

// MARK: StackString32
@StackString(bufferLength: 32)
public struct StackString32 : StackStringProtocol {
}

// MARK: StackString64
@StackString(bufferLength: 64)
public struct StackString64 : StackStringProtocol {
}

// MARK: StackString128
@StackString(bufferLength: 128)
public struct StackString128 : StackStringProtocol {
}

// MARK: StackString256
@StackString(bufferLength: 256)
public struct StackString256 : StackStringProtocol {
}