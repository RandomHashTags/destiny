
import DestinyBlueprint

/// Default Conditional Route Responder implementation where multiple responders are computed at compile time, but only one should be selected based on the request.
public struct ConditionalRouteResponder: ConditionalRouteResponderProtocol {
    public private(set) var staticConditions:[@Sendable (inout any HTTPRequestProtocol) -> Bool]
    public private(set) var staticResponders:[any StaticRouteResponderProtocol]
    public private(set) var dynamicConditions:[@Sendable (inout any HTTPRequestProtocol) -> Bool]
    public private(set) var dynamicResponders:[any DynamicRouteResponderProtocol]

    package var staticConditionsDescription = "[]"
    package var staticRespondersDescription = "[]"
    package var dynamicConditionsDescription = "[]"
    package var dynamicRespondersDescription = "[]"

    public init(
        staticConditions: [@Sendable (inout any HTTPRequestProtocol) -> Bool],
        staticResponders: [any StaticRouteResponderProtocol],
        dynamicConditions: [@Sendable (inout any HTTPRequestProtocol) -> Bool],
        dynamicResponders: [any DynamicRouteResponderProtocol]
    ) {
        self.staticConditions = staticConditions
        self.staticResponders = staticResponders
        self.dynamicConditions = dynamicConditions
        self.dynamicResponders = dynamicResponders
    }

    public var debugDescription: String {
        """
        ConditionalRouteResponder(
            staticConditions: \(staticConditionsDescription),
            staticResponders: \(staticRespondersDescription),
            dynamicConditions: \(dynamicConditionsDescription),
            dynamicResponders: \(dynamicRespondersDescription)
        )
        """
    }

    @inlinable
    public func respond<HTTPRouter: HTTPRouterProtocol & ~Copyable, Socket: HTTPSocketProtocol & ~Copyable>(
        router: borrowing HTTPRouter,
        received: ContinuousClock.Instant,
        loaded: ContinuousClock.Instant,
        socket: borrowing Socket,
        request: inout Socket.ConcreteRequest
    ) async throws -> Bool {
        var request:any HTTPRequestProtocol = request
        for (index, condition) in staticConditions.enumerated() {
            if condition(&request) {
                try await staticResponders[index].write(to: socket)
                return true
            }
        }
        for (index, condition) in dynamicConditions.enumerated() {
            if condition(&request) {
                let responder = dynamicResponders[index]
                var response = responder.defaultResponse
                try await responder.respond(to: socket, request: &request, response: &response)
                //try await router.respondDynamically(received: received, loaded: loaded, socket: socket, request: &request, responder: dynamicResponders[index])
                return true
            }
        }
        return false
    }
}